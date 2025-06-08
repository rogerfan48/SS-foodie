import { gemini20Flash001 } from "@genkit-ai/vertexai";
import { ai } from "../config";
import { z } from "genkit";

const reviewGenerator = ai.definePrompt({
    model: gemini20Flash001,
    name: "reviewGenerator",
    input: { schema: z.string() },
    messages: (input) => {
        return [
            {
                role: "system",
                content: [
                    { text: "You are a smart assistant that can analyze lots of restaurant reviews based on the provided restaurant information." }
                ],
            },
            {
                role: "user",
                content: [
                    { text: `請以一段約20-50字話總結這些評論，突顯最重要的重點，評論內容不能自行生成，要完全根據顧客評論，重點放在常見的主題、正面與負面觀點，以及任何特別突出的評論，並確保摘要清晰易懂。注意：若負面評論為提及原因則忽略該評論。輸出使用繁體中文，去除主詞，只保留描述句，先描述優點再描述缺點。以下為評論內容：\n\n${input}` }, 
                ],
            },
        ];
    },
})

export const summarizeRestaurantReviewFlow = ai.defineFlow({
    name: "summarizeReviewFlow",
    inputSchema: z.array(z.string()),
    outputSchema: z.string(),
},
    async (input) => {
        const reviewTexts = input.map((review, idx) => `Review ${idx + 1}: ${review}`).join("\n\n");
        const response = await reviewGenerator(reviewTexts);

        // Extract the string result from the response
        return typeof response === "string" ? response : response.text ?? "No summary available.";
    }
)