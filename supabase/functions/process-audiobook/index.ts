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
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

// --- HELPER FUNCTIONS ---
function delay(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

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
 * Chuyển văn bản thành audio bằng FPT.AI.
 */
async function textToSpeech(text: string): Promise<Blob> {
  const fptApiKey = Deno.env.get("FPT_AI_API_KEY");
  if (!fptApiKey) {
    throw new Error("FPT_AI_API_KEY is not set in environment variables.");
  }

  // API của FPT.AI có giới hạn khoảng 5000 ký tự mỗi lần gọi.
  // Chúng ta cần chia văn bản dài thành các đoạn nhỏ hơn.
  const MAX_CHARS = 4500; // Để một khoảng an toàn
  const textChunks: string[] = [];
  let currentChunk = "";

  // Chia văn bản theo dấu chấm câu để các đoạn audio nghe tự nhiên hơn
  const sentences = text.match(/[^.!?]+[.!?]+/g) || [text];

  for (const sentence of sentences) {
    if ((currentChunk + sentence).length > MAX_CHARS) {
      textChunks.push(currentChunk);
      currentChunk = sentence;
    } else {
      currentChunk += sentence;
    }
  }
  if (currentChunk) {
    textChunks.push(currentChunk);
  }

  console.log(
    `Text split into ${textChunks.length} chunks for TTS processing.`,
  );

  // Mảng để lưu các file audio nhỏ (dưới dạng ArrayBuffer)
  const audioBuffers: ArrayBuffer[] = [];

  for (const chunk of textChunks) {
    console.log(`Processing chunk of ${chunk.length} characters...`);
    const response = await fetch("https://api.fpt.ai/hmi/tts/v5", {
      method: "POST",
      headers: {
        "api-key": fptApiKey,
        "Content-Type": "application/json",
        // Chọn giọng đọc. 'banmai' là giọng nữ miền Bắc.
        // Bạn có thể đổi thành 'leminh' (nam Bắc), 'myan' (nữ Nam), 'giaan' (nam Nam)...
        "voice": "banmai",
      },
      body: chunk, // API của FPT.AI nhận text trực tiếp trong body
    });

    if (!response.ok) {
      const errorBody = await response.text();
      throw new Error(
        `FPT.AI API failed with status ${response.status}: ${errorBody}`,
      );
    }

    // FPT.AI trả về JSON chứa link audio. Chúng ta cần tải link đó về.
    const resultJson = await response.json();
    if (resultJson.async) {
      const audioUrl = resultJson.async;

      console.log(
        "Waiting for 2 seconds for FPT.AI to process the audio file...",
      );
      await delay(20000);
      console.log(`Downloading audio from: ${audioUrl}`);
      const audioResponse = await fetch(audioUrl);
      if (!audioResponse.ok) {
        throw new Error(
          `Failed to download audio from FPT.AI URL: ${audioUrl}`,
        );
      }
      const buffer = await audioResponse.arrayBuffer();
      audioBuffers.push(buffer);
    } else {
      throw new Error(
        `FPT.AI did not return a valid audio URL. Response: ${
          JSON.stringify(resultJson)
        }`,
      );
    }
  }

  // Nối tất cả các file audio nhỏ lại thành một file duy nhất
  const totalLength = audioBuffers.reduce(
    (sum, buffer) => sum + buffer.byteLength,
    0,
  );
  const combined = new Uint8Array(totalLength);
  let offset = 0;
  for (const buffer of audioBuffers) {
    combined.set(new Uint8Array(buffer), offset);
    offset += buffer.byteLength;
  }

  // Trả về file audio đã nối dưới dạng Blob
  return new Blob([combined], { type: "audio/mpeg" });
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
    const textResponse = await fetch(textUrl);
    if (!textResponse.ok) {
      throw new Error(`Failed to download text file from ${textUrl}`);
    }
    const originalText = await textResponse.text();
    console.log("Text downloaded successfully.");

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
