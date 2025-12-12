// supabase/functions/process-audiobook/index.ts
//test deploy function
import { serve } from "std/http/server.ts";
import { createClient, SupabaseClient } from "@supabase/supabase-js";
import { GoogleGenerativeAI } from "@google/generative-ai";
import { DOMParser } from "deno-dom";
import { Readability } from "readability";
import { encode } from "encode";

// Lấy các biến môi trường
const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");
const GOOGLE_TTS_API_KEY = Deno.env.get("GOOGLE_TTS_API_KEY");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const CLOUDMERSIVE_API_KEY = Deno.env.get("CLOUDMERSIVE_API_KEY");

// --- HELPER FUNCTIONS ---
// function delay(ms: number) {
//   return new Promise((resolve) => setTimeout(resolve, ms));
// }

/**
 * Cập nhật trạng thái của một document trong database.
 */
async function updateDocumentStatus(
  supabaseAdmin: SupabaseClient,
  documentId: string,
  status: string,
  data: object = {},
) {
  const { error } = await supabaseAdmin
    .from("personal_documents")
    .update({ status, ...data })
    .eq("id", documentId);
  if (error) throw error;
}

/**
 * Sử dụng Gemini để tạo tựa đề và mô tả từ văn bản.
 */
async function generateTitleAndDescription(
  text: string,
): Promise<{ title: string; description: string }> {
  if (!GEMINI_API_KEY) {
    throw new Error("GEMINI_API_KEY is not set in environment variables.");
  }
  const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
  const model = genAI.getGenerativeModel({ model: "gemini-2.5-pro" });
  //gemini-2.5-pro
  const prompt = `
    Bạn là một trợ lý biên tập am hiểu văn học Việt Nam. Nhiệm vụ của bạn là phân tích đoạn văn bản dưới đây và thực hiện theo các bước sau:

    1.  **Ưu tiên nhận dạng:** Đầu tiên, hãy kiểm tra xem nội dung văn bản có khớp với một câu chuyện cổ tích, truyện ngụ ngôn, tác phẩm văn học, hoặc bài thơ nổi tiếng nào của Việt Nam không (ví dụ: "Cây tre trăm đốt", "Tấm Cám", "Truyện Kiều", "Chí Phèo"...).
    2.  **Quyết định tựa đề:**
        *   **NẾU** bạn nhận dạng được tác phẩm, hãy sử dụng tên chính xác của tác phẩm đó làm tựa đề.
        *   **NẾU KHÔNG** nhận dạng được, hãy tự tạo một tựa đề ngắn gọn (dưới 10 từ) và phù hợp nhất với nội dung.
    3.  **Tạo mô tả:** Dựa vào nội dung, hãy viết một đoạn mô tả ngắn gọn và hấp dẫn (dưới 50 từ).
    4.  **Định dạng đầu ra:** Trả lời bằng một đối tượng JSON hợp lệ, không có bất kỳ văn bản nào khác bao quanh. Đối tượng JSON phải có hai key là "title" và "description".

    Văn bản cần phân tích: """
    ${text.substring(0, 8000)}
    """
  `; // Giới hạn text để tránh vượt quá giới hạn token của Gemini

  const result = await model.generateContent(prompt);
  const response = result.response;
  let jsonString = response.text();
  console.log("Raw response from Gemini:", jsonString);

  // Logic để "dọn dẹp" chuỗi trả về từ Gemini
  // Tìm kiếm chuỗi bắt đầu bằng '{' và kết thúc bằng '}'
  const jsonMatch = jsonString.match(/\{[\s\S]*\}/);

  if (jsonMatch) {
    // Nếu tìm thấy, lấy chuỗi JSON đó
    jsonString = jsonMatch[0];
  } else {
    // Nếu không tìm thấy JSON, báo lỗi
    throw new Error("Could not extract valid JSON from Gemini's response.");
  }

  // Parse chuỗi JSON
  const parsedResult = JSON.parse(jsonString);
  return {
    title: parsedResult.title || "Không thể tạo tựa đề",
    description: parsedResult.description || "Không thể tạo mô tả",
  };
}
/**
 * Sử dụng Gemini để làm sạch và trích xuất nội dung chính từ văn bản thô.
 */
async function extractMainContent(rawText: string): Promise<string> {
  // Nếu text thô quá ngắn, không cần xử lý qua AI, trả về luôn.
  if (rawText.length < 400) {
    return rawText;
  }

  if (!GEMINI_API_KEY) {
    throw new Error("GEMINI_API_KEY is not set in environment variables.");
  }

  const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
  const model = genAI.getGenerativeModel({ model: "gemini-2.5-pro" });

  // Prompt mới: Ngắn gọn, súc tích và tập trung vào kết quả
  const prompt = `
    Nhiệm vụ: Phân tích văn bản dưới đây và trích xuất nội dung của bài viết hoặc câu chuyện.
    Yêu cầu:
    1. Loại bỏ hoàn toàn các thành phần phụ như menu, quảng cáo, "xem thêm", bình luận, chân trang.
    2. Chỉ giữ lại phần thân bài chính.
    3. Trả về văn bản thuần túy đã được làm sạch. Không thêm bất kỳ lời giải thích hay định dạng nào.

    Văn bản cần xử lý:
    """
    ${rawText.substring(0, 15000)}
    """
  `; // Tăng giới hạn lên một chút để có ngữ cảnh tốt hơn

  try {
    const result = await model.generateContent(prompt);
    const response = result.response;
    const cleanedText = response.text();

    // Nếu kết quả trả về quá ngắn một cách bất thường, có thể AI đã lọc sai.
    // Trong trường hợp đó, hãy trả về text gốc để đảm bảo không mất nội dung.
    if (cleanedText.length < rawText.length * 0.2) { // Nếu kết quả ít hơn 20% bản gốc
      console.warn(
        "AI cleaning resulted in unusually short text. Falling back to raw text.",
      );
      return rawText;
    }

    return cleanedText;
  } catch (error) {
    console.error(
      "Error during Gemini content cleaning. Falling back to raw text.",
      error,
    );
    // Nếu có lỗi xảy ra trong quá trình làm sạch, hãy trả về text thô ban đầu.
    // Điều này đảm bảo ứng dụng không bị crash chỉ vì bước làm sạch thất bại.
    return rawText;
  }
}
/**
 * Chuyển văn bản thành audio sử dụng Google Cloud Text-to-Speech.
 */
/**
 * Chuyển văn bản dài thành audio, chia nhỏ và ghép lại thủ công.
 */
async function textToSpeech(
  text: string,
  preferredVoice?: string | null,
): Promise<Blob> {
  if (!GOOGLE_TTS_API_KEY) {
    throw new Error("GOOGLE_TTS_API_KEY is not set in environment variables.");
  }

  const API_ENDPOINT =
    `https://texttospeech.googleapis.com/v1/text:synthesize?key=${GOOGLE_TTS_API_KEY}`;
  const CHUNK_LIMIT_BYTES = 4800;

  // 1. Chia văn bản thành các đoạn nhỏ (logic này giữ nguyên)
  const textEncoder = new TextEncoder();
  const textChunks: string[] = [];
  let currentChunk = "";
  const sentences = text.match(/[^.!?]+[.!?]+/g) || [text];

  for (const sentence of sentences) {
    const potentialChunk = currentChunk + sentence;
    if (textEncoder.encode(potentialChunk).length > CHUNK_LIMIT_BYTES) {
      if (currentChunk) textChunks.push(currentChunk);
      currentChunk = sentence;
    } else {
      currentChunk = potentialChunk;
    }
  }
  if (currentChunk) textChunks.push(currentChunk);

  console.log(`Text split into ${textChunks.length} chunks.`);

  // 2. Gọi API TTS cho từng đoạn và thu thập dữ liệu audio dưới dạng Uint8Array
  const audioDataParts: Uint8Array[] = [];
  const chunksToProcess = textChunks.slice(0, 3); // Giới hạn xử lý tối đa 3 đoạn để thử nghiệm
  for (let i = 0; i < chunksToProcess.length; i++) {
    console.log(`Processing audio chunk ${i + 1}/${chunksToProcess.length}...`);

    const selectedVoiceName = preferredVoice || "vi-VN-Standard-A"; // Giọng Nữ Miền Bắc làm mặc định
    console.log(`Using voice: ${selectedVoiceName}`);
    const requestBody = {
      input: { text: chunksToProcess[i] },
      voice: { languageCode: "vi-VN", name: selectedVoiceName },
      audioConfig: { audioEncoding: "MP3" },
    };

    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Achernar FEMALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Achird	MALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Algenib	MALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Algieba	MALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Alnilam	MALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Aoede	FEMALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Autonoe	FEMALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Callirrhoe	FEMALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Charon	MALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Despina	FEMALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Enceladus	MALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Erinome	FEMALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Fenrir	MALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Gacrux	FEMALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Iapetus	MALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Kore	FEMALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Laomedeia	FEMALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Leda	FEMALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Orus	MALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Puck	MALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Pulcherrima	FEMALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Rasalgethi	MALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Sadachbia	MALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Sadaltager	MALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Schedar	MALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Sulafat	FEMALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Umbriel	MALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Vindemiatrix	FEMALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Zephyr	FEMALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Chirp3-HD-Zubenelgenubi	MALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Neural2-A	FEMALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Neural2-D	MALE
    // Vietnamese (Vietnam)	Standard	vi-VN	vi-VN-Standard-A	FEMALE
    // Vietnamese (Vietnam)	Standard	vi-VN	vi-VN-Standard-B	MALE
    // Vietnamese (Vietnam)	Standard	vi-VN	vi-VN-Standard-C	FEMALE
    // Vietnamese (Vietnam)	Standard	vi-VN	vi-VN-Standard-D	MALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Wavenet-A	FEMALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Wavenet-B	MALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Wavenet-C	FEMALE
    // Vietnamese (Vietnam)	Premium	vi-VN	vi-VN-Wavenet-D	MALE
    const response = await fetch(API_ENDPOINT, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(requestBody),
    });

    if (!response.ok) {
      const errorBody = await response.json();
      throw new Error(`Google TTS API failed: ${JSON.stringify(errorBody)}`);
    }

    const responseData = await response.json();
    const audioContent = responseData.audioContent;
    if (!audioContent) continue;

    const dataUrl = `data:audio/mpeg;base64,${audioContent}`;
    const audioResponse = await fetch(dataUrl);
    const audioArrayBuffer = await audioResponse.arrayBuffer();
    audioDataParts.push(new Uint8Array(audioArrayBuffer));
  }

  if (audioDataParts.length === 0) {
    throw new Error("No audio parts were generated.");
  }

  // 3. Ghép các file audio lại (thay thế mp3cat)
  console.log("Concatenating audio parts manually...");

  // Tính tổng độ dài của tất cả các phần
  const totalLength = audioDataParts.reduce(
    (acc, part) => acc + part.length,
    0,
  );

  // Tạo một mảng Uint8Array lớn duy nhất
  const concatenatedMp3 = new Uint8Array(totalLength);

  // Copy dữ liệu từ từng phần vào mảng lớn
  let offset = 0;
  for (const part of audioDataParts) {
    concatenatedMp3.set(part, offset);
    offset += part.length;
  }

  // 4. Tạo Blob từ file đã ghép
  return new Blob([concatenatedMp3.buffer], { type: "audio/mpeg" });
}
/** Sử dụng Gemini để trích xuất văn bản từ hình ảnh.
 */
async function extractTextFromImage(imageBlob: Blob): Promise<string> {
  if (!GEMINI_API_KEY) {
    throw new Error("GEMINI_API_KEY is not set in environment variables.");
  }
  const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
  // Sử dụng model có khả năng nhận diện hình ảnh, ví dụ 'gemini-1.5-pro-latest'
  const model = genAI.getGenerativeModel({ model: "gemini-2.5-pro" });

  // 1. Chuyển đổi Blob thành ArrayBuffer
  const image_bytes = await imageBlob.arrayBuffer();

  // 2. Sử dụng hàm `encode` từ thư viện chuẩn của Deno để chuyển đổi an toàn
  // thay vì dùng btoa và spread operator.
  const base64Image = encode(image_bytes);

  const prompt =
    "Trích xuất tất cả văn bản có trong hình ảnh này. Chỉ trả về phần văn bản, không thêm bất kỳ lời giải thích nào. Loại bỏ các thành phần không phải nội dung văn bản.";

  const imagePart = {
    inlineData: {
      mimeType: imageBlob.type,
      data: base64Image,
    },
  };

  console.log("Sending image to Gemini Vision...");

  const result = await model.generateContent([prompt, imagePart]);
  const response = result.response;
  const text = response.text();

  return text;
}
// --- MAIN FUNCTION ---

serve(async (req) => {
  // Khởi tạo Supabase Admin Client
  const supabaseAdmin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    SUPABASE_SERVICE_ROLE_KEY!,
  );

  let documentId: string | null = null;

  try {
    // 1. Lấy record từ request body mà Database Webhook gửi
    const { record } = await req.json();
    documentId = record.id;
    const uploadedFileUrl = record.extracted_text_url;
    const sourceType = record.source_type;
    // `original_source` sẽ chứa URL web, hoặc tên file gốc
    const originalSource = record.original_source;
    const userId = record.user_id;

    if (!documentId || !userId || !sourceType) {
      throw new Error(
        "Missing core data in webhook payload (id, user_id, or source_type).",
      );
    }

    console.log(`Processing document ID: ${documentId}`);

    // 2. Cập nhật status thành "processing" để người dùng biết
    await updateDocumentStatus(supabaseAdmin, documentId, "processing");
    let rawText = "";
    // 3. Tải nội dung text từ Supabase Storage
    // const textResponse = await fetch(textUrl);
    // if (!textResponse.ok) {
    //   throw new Error(`Failed to download text file from ${textUrl}`);
    // }
    // const originalText = await textResponse.text();
    // console.log("Text downloaded successfully.");

    // 3. Tải nội dung text từ Supabase Storage
    if (sourceType === "url") {
      console.log(`Extracting content from URL: ${originalSource}`);
      try {
        // 1. Tải HTML từ URL
        const response = await fetch(originalSource);
        if (!response.ok) {
          throw new Error(
            `Failed to fetch URL with status: ${response.status}`,
          );
        }
        const html = await response.text();

        // 2. Tạo một môi trường DOM ảo
        const doc = new DOMParser().parseFromString(html, "text/html");

        if (!doc) {
          throw new Error("Failed to parse HTML document.");
        }

        // 3. Sử dụng Readability để trích xuất bài viết
        const reader = new Readability(doc);
        const article = reader.parse();

        if (!article || !article.textContent) {
          throw new Error(
            "Could not extract main content from the URL using Readability.",
          );
        }

        // article.textContent đã là text thuần, không cần xóa HTML
        rawText = article.textContent.trim();
        console.log("Content extracted from URL successfully.");
      } catch (extractError) {
        // Kiểm tra xem extractError có phải là một instance của Error hay không
        if (extractError instanceof Error) {
          // Nếu đúng, chúng ta có thể truy cập .message một cách an toàn
          throw new Error(`Failed to extract article: ${extractError.message}`);
        }
        // Nếu không, chúng ta chuyển đổi nó thành chuỗi để báo lỗi
        throw new Error(`Failed to extract article: ${String(extractError)}`);
      }

      //*** */
    } else if (sourceType === "file") {
      // --- LUỒNG CŨ: XỬ LÝ TỪ FILE (PDF/DOCX/TXT) ---
      // Kiểm tra xem có URL file đã upload không
      if (!uploadedFileUrl) {
        throw new Error("File source type but no uploaded file URL found.");
      }

      // Tải file từ Supabase Storage (logic này giữ nguyên)
      const urlParts = uploadedFileUrl.split("/");
      const bucketName = urlParts[urlParts.length - 3];
      const filePath = urlParts.slice(urlParts.length - 2).join("/");

      console.log(`Downloading from bucket: ${bucketName}, path: ${filePath}`);

      const { data: fileBlob, error: downloadError } = await supabaseAdmin
        .storage
        .from(bucketName)
        .download(filePath);

      if (downloadError) throw downloadError;
      if (!fileBlob) throw new Error("Downloaded file is null.");

      console.log("Initial file downloaded successfully.");

      // Lấy kiểu MIME của file để phân biệt
      const fileMimeType = fileBlob.type;
      console.log(`Detected file MIME type: ${fileMimeType}`);

      // 1. Ưu tiên kiểm tra nếu là file ảnh
      if (fileMimeType.startsWith("image/")) {
        // --- LUỒNG MỚI: XỬ LÝ ẢNH ---
        console.log(
          "Detected image file. Extracting text using Gemini Vision...",
        );
        rawText = await extractTextFromImage(fileBlob); // Gọi hàm helper mới
        console.log("Text extracted from image successfully.");
      } // Phân luồng phụ dựa trên bucket để trích xuất text (logic này giữ nguyên)
      else if (bucketName === "personal-files-uploads") {
        console.log(
          "Detected uploaded file. Extracting text via Cloudmersive...",
        );
        if (!CLOUDMERSIVE_API_KEY) {
          throw new Error("CLOUDMERSIVE_API_KEY is not set.");
        }
        const formData = new FormData();
        formData.append("inputFile", fileBlob);
        const extractResponse = await fetch(
          "https://api.cloudmersive.com/convert/autodetect/to/txt",
          {
            method: "POST",
            headers: { "Apikey": CLOUDMERSIVE_API_KEY },
            body: formData,
          },
        );
        if (!extractResponse.ok) {
          throw new Error(
            `Cloudmersive API failed: ${await extractResponse.text()}`,
          );
        }
        rawText = await extractResponse.text();
        console.log("Text extracted from file successfully.");
      } else if (bucketName === "personal-texts") {
        console.log("Detected pasted text. Reading content...");
        rawText = await fileBlob.text();
        console.log("Text loaded from .txt file successfully.");
      } else {
        throw new Error(
          `Unknown or unhandled bucket for file source: ${bucketName}`,
        );
      }
    } else {
      throw new Error(`Unsupported source type: ${sourceType}`);
    }
    // Sau khi có text thô, gọi Gemini để làm sạch nó
    const originalText = await extractMainContent(rawText);
    console.log("Text cleaned successfully.");

    console.log("Fetching user's preferred voice...");
    let preferredVoice: string | null = null;

    // Query bảng profiles để lấy giọng đọc của user
    const { data: profile, error: profileError } = await supabaseAdmin
      .from("profiles")
      .select("preferred_voice")
      .eq("id", userId)
      .single(); // Lấy duy nhất 1 record

    if (profileError) {
      console.warn(
        `Could not fetch profile for user ${userId}:`,
        profileError.message,
      );
      // Không ném lỗi, chỉ cảnh báo và tiếp tục với giọng đọc mặc định
    } else if (profile && profile.preferred_voice) {
      preferredVoice = profile.preferred_voice;
      console.log(`Found preferred voice: ${preferredVoice}`);
    } else {
      console.log("No preferred voice set for user. Using default.");
    }
    // 4. (AI BƯỚC 1) Gọi Gemini để tạo tựa đề và mô tả
    const { title, description } = await generateTitleAndDescription(
      originalText,
    );
    console.log(`Generated Title: ${title}`);
    console.log(`Generated Description: ${description}`);

    // 5. (AI BƯỚC 2) Gọi dịch vụ TTS để tạo audio
    const audioBlob = await textToSpeech(originalText, preferredVoice);
    console.log("Audio generated successfully.");

    // 6. Upload file audio lên Storage
    const audioFileName = `${crypto.randomUUID()}.mp3`;
    const audioStoragePath = `${userId}/${audioFileName}`;

    const { error: uploadError } = await supabaseAdmin.storage
      .from("personal-audios")
      .upload(audioStoragePath, audioBlob, {
        contentType: "audio/mpeg",
        upsert: false,
      });

    if (uploadError) throw uploadError;
    console.log("Audio uploaded to storage.");

    // 7. Lấy URL công khai của file audio
    const { data: { publicUrl: generatedAudioUrl } } = supabaseAdmin.storage
      .from("personal-audios")
      .getPublicUrl(audioStoragePath);

    // 8. Cập nhật record lần cuối với đầy đủ thông tin
    await updateDocumentStatus(supabaseAdmin, documentId, "completed", {
      title,
      description,
      generated_audio_url: generatedAudioUrl,
    });
    console.log(`Document ID: ${documentId} processed successfully!`);

    return new Response(
      JSON.stringify({ success: true, message: "Processing complete." }),
      {
        headers: { "Content-Type": "application/json" },
        status: 200,
      },
    );
  } catch (error) {
    console.error("Error processing document:", error);

    // Nếu có lỗi, cập nhật status của document thành 'error'
    if (documentId) {
      await updateDocumentStatus(supabaseAdmin, documentId, "error");
    }

    let errorMessage = "An unknown error occurred.";
    // Kiểm tra xem error có phải là một instance của Error hay không
    if (error instanceof Error) {
      errorMessage = error.message;
    }

    // Trả về errorMessage đã được xử lý an toàn
    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
