// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
// import "jsr:@supabase/functions-js/edge-runtime.d.ts"

// console.log("Hello from Functions!")

// Deno.serve(async (req) => {
//   const { name } = await req.json()
//   const data = {
//     message: `Hello ${name}!`,
//   }

//   return new Response(
//     JSON.stringify(data),
//     { headers: { "Content-Type": "application/json" } },
//   )
// })

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/process-audiobook' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/

// supabase/functions/process-audiobook/index.ts
//test deploy function
import { serve } from "std/http/server.ts";
import { createClient, SupabaseClient } from "@supabase/supabase-js";
import { GoogleGenerativeAI } from "@google/generative-ai";

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
    Dựa vào đoạn văn bản sau, hãy tạo ra một tựa đề ngắn gọn (dưới 10 từ) và một đoạn mô tả hấp dẫn (dưới 50 từ).
    Hãy trả lời bằng một đối tượng JSON hợp lệ, không có bất kỳ văn bản nào khác bao quanh.
    Đối tượng JSON phải có hai key là "title" và "description".

    Văn bản: """
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
 * Sử dụng Gemini để trích xuất nội dung chính từ văn bản thô.
 */
async function extractMainContent(rawText: string): Promise<string> {
  if (!GEMINI_API_KEY) {
    throw new Error("GEMINI_API_KEY is not set in environment variables.");
  }
  console.log("Extracting main content with Gemini...");

  const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
  const model = genAI.getGenerativeModel({ model: "gemini-2.5-pro" });

  const prompt = `
    Phân tích văn bản thô dưới đây. Nhiệm vụ của bạn là hoạt động như một bộ lọc thông minh,
    chỉ trích xuất và trả về phần nội dung chính của bài viết hoặc câu chuyện.
    Hãy loại bỏ tất cả các yếu tố không liên quan như:
    - Tiêu đề, đầu trang (headers), chân trang (footers), số trang.
    - Menu điều hướng, các liên kết "Xem thêm", "Bài viết liên quan".
    - Tên tác giả và thông tin xuất bản nếu chúng không phải là một phần của câu chuyện.
    - Quảng cáo, thông báo cookie, các nút kêu gọi hành động.
    - Bình luận của người dùng.
    Chỉ trả về phần văn bản thuần túy của nội dung chính. Không thêm bất kỳ lời giải thích nào.

    Văn bản thô: """
    ${rawText.substring(0, 10000)} 
    """
  `; // Tăng giới hạn một chút cho bước này

  const result = await model.generateContent(prompt);
  const response = result.response;

  console.log("Main content extracted.");
  return response.text();
}
/**
 * Chuyển văn bản thành audio sử dụng Google Cloud Text-to-Speech.
 */
/**
 * Chuyển văn bản dài thành audio, chia nhỏ và ghép lại thủ công.
 */
async function textToSpeech(text: string): Promise<Blob> {
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
    const requestBody = {
      input: { text: chunksToProcess[i] },
      voice: { languageCode: "vi-VN", name: "vi-VN-Chirp3-HD-Iapetus" },
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
    const textUrl = record.extracted_text_url;
    const userId = record.user_id;

    if (!documentId || !textUrl || !userId) {
      throw new Error("Missing required data in webhook payload.");
    }

    console.log(`Processing document ID: ${documentId}`);

    // 2. Cập nhật status thành "processing" để người dùng biết
    await updateDocumentStatus(supabaseAdmin, documentId, "processing");

    // 3. Tải nội dung text từ Supabase Storage
    // const textResponse = await fetch(textUrl);
    // if (!textResponse.ok) {
    //   throw new Error(`Failed to download text file from ${textUrl}`);
    // }
    // const originalText = await textResponse.text();
    // console.log("Text downloaded successfully.");

    // 3. Tải nội dung text từ Supabase Storage
    const urlParts = textUrl.split("/");
    const bucketName = urlParts[urlParts.length - 3];
    const filePath = urlParts.slice(urlParts.length - 2).join("/");

    console.log(`Downloading from bucket: ${bucketName}, path: ${filePath}`);

    const { data: fileBlob, error: downloadError } = await supabaseAdmin.storage
      .from(bucketName)
      .download(filePath);

    if (downloadError) throw downloadError;
    if (!fileBlob) throw new Error("Downloaded file is null.");

    console.log("Initial file downloaded successfully.");

    let rawText = "";

    // Phân luồng xử lý dựa trên bucket chứa file
    if (bucketName === "personal-files-uploads") {
      // LUỒNG MỚI: XỬ LÝ FILE PDF/DOCX
      console.log("Detected uploaded file. Extracting text...");
      if (!CLOUDMERSIVE_API_KEY) {
        throw new Error("CLOUDMERSIVE_API_KEY is not set.");
      }

      const formData = new FormData();
      formData.append("inputFile", fileBlob);

      // Gọi API của Cloudmersive để tự động nhận diện và chuyển đổi sang text
      const extractResponse = await fetch(
        "https://api.cloudmersive.com/convert/autodetect/to/txt",
        {
          method: "POST",
          headers: { "Apikey": CLOUDMERSIVE_API_KEY },
          body: formData,
        },
      );

      if (!extractResponse.ok) {
        const errorText = await extractResponse.text();
        throw new Error(`Cloudmersive API failed: ${errorText}`);
      }

      rawText = await extractResponse.text();
      console.log("Text extracted from file successfully.");
    } else if (bucketName === "personal-texts") {
      // LUỒNG CŨ: XỬ LÝ FILE .TXT TỪ VĂN BẢN DÁN VÀO
      console.log("Detected pasted text. Reading content...");
      rawText = await fileBlob.text();
      console.log("Text loaded from .txt file successfully.");
    } else {
      throw new Error(`Unknown or unhandled bucket: ${bucketName}`);
    }
    // Sau khi có text thô, gọi Gemini để làm sạch nó
    const originalText = await extractMainContent(rawText);
    console.log("Text cleaned successfully.");
    
    // 4. (AI BƯỚC 1) Gọi Gemini để tạo tựa đề và mô tả
    const { title, description } = await generateTitleAndDescription(
      originalText,
    );
    console.log(`Generated Title: ${title}`);
    console.log(`Generated Description: ${description}`);

    // 5. (AI BƯỚC 2) Gọi dịch vụ TTS để tạo audio
    const audioBlob = await textToSpeech(originalText);
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

    return new Response(JSON.stringify({ message: error }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
