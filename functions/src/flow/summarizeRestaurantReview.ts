import { gemini20Flash001 } from "@genkit-ai/vertexai";
import { ai } from "../config";
import { z } from "genkit";
import * as admin from 'firebase-admin';

if (admin.apps.length === 0) {
  admin.initializeApp();
}
const db = admin.firestore();

const reviewGenerator = ai.definePrompt({
    model: gemini20Flash001,
    name: "reviewGenerator",
    input: { schema: z.object({
        dishNames: z.string(),
        reviews: z.string()
    })  },
    messages: (input) => {
        return [
            {
                role: "system",
                content: [
                    { text: `You are a smart assistant that can analyze lots of restaurant reviews based on the provided restaurant information. Following is the dish names of this restaurant:\n\n${input.dishNames}` }
                ],
            },
            {
                role: "user",
                content: [
                    { text: `第一段的內容請以約20-50字描述該餐廳的餐點類型。第二段請以一段約20-50字話總結提供的評論，內容需完全根據提供的顧客評論、不能自行生成，重點放在「常見的主題」、「正面」與「負面」觀點，並確保摘要清晰易懂。注意：若負面評論沒有說明原因必須忽略該評論，且該負面內容需占整體評論的40%以上才會納入考慮。。輸出使用繁體中文，去除主詞，只保留描述句，先描述優點再描述缺點。以下為評論內容：\n\n${input}` }, 
                ],
            },
        ];
    },
})

async function findAllDishes(restaurantId: string): Promise<string[]> {
    try {
        const dishesSnapshot = await db
            .collection('apps')
            .doc('foodie')
            .collection('restaurants')
            .doc(restaurantId)
            .collection('menu')
            .get();

        if (dishesSnapshot.empty) {
            console.log(`No dishes found for restaurant ID: ${restaurantId}`);
            return [];
        }

        const dishNames: string[] = [];
        dishesSnapshot.forEach(dishDoc => {
            const dishData = dishDoc.data();
            if (dishData && dishData.dishName) {
                dishNames.push(dishData.dishName);
            } else {
                console.warn(`Dish document ${dishDoc.id} in restaurant ${restaurantId} is missing a dishName.`);
            }
        });

        return dishNames;
    } catch (error) {
        console.error(`Error finding all dishes for restaurant ${restaurantId}:`, error);
        return []; // Return empty array on error
    }
}

export const summarizeRestaurantReviewFlow = ai.defineFlow({
    name: "summarizeRestaurantReviewFlow",
    inputSchema: z.object({
        restaurandId: z.string().describe("The ID of the restaurant to summarize reviews for"),
        reviews: z.array(z.string()).describe("Array of restaurant reviews to summarize"),
    }),
    outputSchema: z.string(),
},
    async (input) => {
        const { restaurandId, reviews } = input;
        const dishNames = await findAllDishes(restaurandId);
        const dishNamesText = dishNames.join(", ");
        const reviewTexts = reviews.map((review, idx) => `Review ${idx + 1}: ${review}`).join("\n\n");
        const response = await reviewGenerator({
            dishNames: dishNamesText,
            reviews: reviewTexts
        });

        // Extract the string result from the response
        return typeof response === "string" ? response : response.text ?? "No summary available.";
    }
)