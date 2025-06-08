import { gemini20Flash001 } from "@genkit-ai/vertexai";
import { ai } from "../config";
import { z } from "genkit";

export const reviewGenerator = ai.definePrompt({
    model: gemini20Flash001,
    name: "reviewGenerator",
    input: { schema: z.string() },
    messages: (input) => {
        return [
            {
                role: "system",
                content: [
                    { text: "You are a smart assistant that generates detailed restaurant reviews based on the provided restaurant information." }
                ],
            },
            {
                role: "user",
                content: [
                    { text: `Here are some customer reviews, please provide a short summary covering overall sentiment and key highlights:\n${input}` }
                ],
            },
        ];
    },
})

export const summarizeReviewFlow = ai.defineFlow({
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