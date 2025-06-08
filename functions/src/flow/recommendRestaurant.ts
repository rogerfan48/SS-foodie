// filepath: c:\WorkspaceFlutter\foodie\functions\src\flow\recommendRestaurant.ts
import { gemini20Flash001 } from "@genkit-ai/vertexai";
import { ai } from "../config"; // Your Genkit AI configuration
import { z } from "genkit";
import * as admin from 'firebase-admin';

// Initialize Firebase Admin SDK.
if (admin.apps.length === 0) {
  admin.initializeApp();
}
const db = admin.firestore();

interface Dish {
    name: string;
    bestReviewSummary: string;
    price: number;
}

interface Restaurant {
    restaurantId: string;
    name: string;
    dishes: Dish[];
    genreTags: string[];
}

// Helper function to fetch user's viewed restaurant IDs
async function getUserViewedRestaurantIds(userId: string): Promise<string[]> {
    try {
        const userDocRef = db.collection('apps').doc('foodie').collection('users').doc(userId);
        const userDoc = await userDocRef.get();

        if (userDoc.exists) {
            const userData = userDoc.data();
            const viewedRestaurantIDsMap = userData?.viewedRestaurantIDs;

            if (viewedRestaurantIDsMap && typeof viewedRestaurantIDsMap === 'object' && Object.keys(viewedRestaurantIDsMap).length > 0) {
                // This array will store individual view events, not just the latest per restaurant
                const allViewEvents: { restaurantId: string; viewDate: Date }[] = [];

                for (const restaurantId in viewedRestaurantIDsMap) {
                    if (Object.prototype.hasOwnProperty.call(viewedRestaurantIDsMap, restaurantId)) {
                        const viewDatesArray = viewedRestaurantIDsMap[restaurantId];
                        if (Array.isArray(viewDatesArray) && viewDatesArray.length > 0) {
                            const validDates = viewDatesArray
                                .map(dateStr => new Date(dateStr))
                                .filter(date => !isNaN(date.getTime()));

                            // Instead of finding the latest, add each valid date as a separate event
                            validDates.forEach(date => {
                                allViewEvents.push({ restaurantId, viewDate: date });
                            });
                        }
                    }
                }

                // Sort all view events by viewDate in descending order (most recent first)
                allViewEvents.sort((a, b) => b.viewDate.getTime() - a.viewDate.getTime());

                // Map to restaurant IDs. This list may contain duplicates.
                return allViewEvents.map(item => item.restaurantId);
            } else {
                if (!viewedRestaurantIDsMap || Object.keys(viewedRestaurantIDsMap).length === 0) {
                    // console.log(`User ${userId} has no viewed restaurants in viewedRestaurantIDsMap.`);
                } else {
                    console.error(`User ${userId} has viewedRestaurantIDsMap, but it's not in the expected format or is empty.`);
                }
            }
        } else {
            // console.log(`User document not found for ${userId}.`);
        }
        return [];
    } catch (error) {
        console.error(`Error fetching user history for ${userId}:`, error);
        return []; // Return empty array on error
    }
}

// Helper function to find all restaurants with their dishes
async function findAllRestaurants(): Promise<Restaurant[]> {
    try {
        const restaurantsSnapshot = await db.collection('apps').doc('foodie').collection('restaurants').get();

        if (restaurantsSnapshot.empty) {
            return [];
        }

        const restaurants: Restaurant[] = [];

        for (const restaurantDoc of restaurantsSnapshot.docs) {
            const restaurantId = restaurantDoc.id;
            const restaurantData = restaurantDoc.data();

            // Fetch dishes for the current restaurant
            const dishesSnapshot = await db
                .collection('apps')
                .doc('foodie')
                .collection('restaurants')
                .doc(restaurantId)
                .collection('menu')
                .get();

            const dishes: Dish[] = [];
            if (!dishesSnapshot.empty) {
                dishesSnapshot.forEach(dishDoc => {
                    const dishData = dishDoc.data();
                    // Assuming dish documents match the Dish interface
                    dishes.push({
                        name: dishData.dishName || 'Unknown Dish',
                        bestReviewSummary: dishData.bestReviewSummary || '',
                        price: dishData.dishPrice || 0,
                    } as Dish);
                });
            }

            restaurants.push({
                restaurantId: restaurantId,
                name: restaurantData.restaurantName || 'Unknown Restaurant',
                genreTags: restaurantData.genreTags || [],
                dishes: dishes,
            } as Restaurant);
        }
        return restaurants;
    } catch (error) {
        console.error("Error finding all restaurants:", error);
        return []; // Return empty array on error
    }
}

// New helper function for generating history summary, extracted from recommendationPrompt.messages
async function generateHistoryRestaurantNameForPrompt(
    viewedRestaurantIds: string[],
    allRestaurantsData: Restaurant[],
    userId: string
): Promise<string> {
    let historySummary = "No viewing history available.";

    if (viewedRestaurantIds.length > 0) {
        // Use allRestaurantsData to find names for viewedRestaurantIDs
        const viewedNames = viewedRestaurantIds.map(id => {
            const foundRestaurant = allRestaurantsData.find(r => r.restaurantId === id);
            return foundRestaurant ? foundRestaurant.name : null;
        }).filter(Boolean).join(', ');

        if (viewedNames) {
            historySummary = `User has recently viewed restaurants: ${viewedNames}.`;
        } else {
            // This case might happen if viewed IDs are stale and not in current allRestaurantsData
            historySummary = `User has recently viewed restaurants with IDs: ${viewedRestaurantIds.join(', ')} (names could not be found in current restaurant list).`;
        }
    } else if ((await db.collection('apps').doc('foodie').collection('users').doc(userId).get()).exists) {
        historySummary = "User has no recorded viewing history.";
        console.warn(`User ${userId} has no viewedRestaurantIDs or document exists but no history.`);
    } else {
        historySummary = "User document not found or no viewing history.";
        console.warn(`User ${userId} document not found or has no viewing history.`);
    }
    return historySummary;
}

// New helper function for generating the all restaurants prompt section
function generateAllRestaurantsInfoForPrompt(allRestaurantsData: Restaurant[]): string {
    let section = "No restaurants found in the database.";
    if (allRestaurantsData.length > 0) {
        section = "Here is a list of all available restaurants and their details:\n";
        allRestaurantsData.forEach(restaurant => {
            section += `\nRestaurant Name: ${restaurant.name} (ID: ${restaurant.restaurantId})\n`;
            section += `Genre Tags: ${restaurant.genreTags.join(', ') || 'N/A'}\n`;
            if (restaurant.dishes.length > 0) {
                section += "Dishes:\n";
                restaurant.dishes.forEach(dish => {
                    section += `  - Name: ${dish.name}, Price: ${dish.price}, Review Summary: ${dish.bestReviewSummary || 'N/A'}\n`;
                });
            } else {
                section += "Dishes: No dishes listed.\n";
            }
        });
        // Consider truncating if too long:
        // const MAX_PROMPT_RESTAURANTS_SECTION_LENGTH = 10000; // Adjust as needed
        // if (section.length > MAX_PROMPT_RESTAURANTS_SECTION_LENGTH) {
        //    section = section.substring(0, MAX_PROMPT_RESTAURANTS_SECTION_LENGTH) + "\n... (list truncated due to length)";
        // }
    }
    return section;
}

const recommendationPrompt = ai.definePrompt({
    model: gemini20Flash001,
    name: "recommendationPrompt",
    input: { schema: z.object({
                viewedRestaurantIds: z.array(z.string()).describe("List of restaurant IDs the user has viewed."),
                allRestaurantsData: z.array(
                    z.object({
                        restaurantId: z.string().describe("The unique ID of the restaurant."),
                        name: z.string().describe("The name of the restaurant."),
                        genreTags: z.array(z.string()).describe("List of genre tags associated with the restaurant."),
                        dishes: z.array(
                            z.object({
                                name: z.string().describe("The name of the dish."),
                                bestReviewSummary: z.string().describe("A summary of the best review for the dish."),
                                price: z.number().describe("The price of the dish."),
                            })).describe("List of dishes available at the restaurant."),
                    })).describe("List of all restaurants with their details."),
                messages: z.array(
                    z.object({
                        isUser: z.boolean().describe("True if the message is from the user, false if from the AI."),
                        text: z.string().describe("The text content of the message."),
                    })).describe("The history of messages in the conversation."), 
                userId: z.string().describe("The ID of the user requesting recommendations."),
    }) },
    messages: async (input) => {

        const { viewedRestaurantIds, allRestaurantsData, messages, userId } = input;
        const historySummary = await generateHistoryRestaurantNameForPrompt(viewedRestaurantIds, allRestaurantsData, userId);
        const allRestaurantsPromptSection = generateAllRestaurantsInfoForPrompt(allRestaurantsData);

        let userPromptText = '';
        // 3. Construct a prompt for the LLM using the defined prompt
        let systemPromptText =   
           `You are a friendly and helpful restaurant recommendation assistant.
            User's recent restaurant browsing history (from latest to oldest):
            ${historySummary}

            All available restaurants in our database:
            ${allRestaurantsPromptSection}`;

        if (messages && messages.length > 0) {
            messages.forEach(msg => {
                userPromptText += `${msg.isUser ? 'User' : 'Assistant'}: ${msg.text}\n`;
            });
        } 

        systemPromptText += `
Your task is to decide the next step based on the user's viewing history, the list of all available restaurants, and the entire conversation history:
1.  If you have enough information to confidently recommend one or more restaurants from the provided list,
    output the criteria you used and the IDs of the recommended restaurants. The format MUST be:
    RECOMMEND: {"criteria_summary": "A user-friendly explanation of why these are recommended, e.g., 'Since you're looking for vibrant Italian places, you might enjoy [Restaurant Name] for its popular lasagna and great atmosphere!' or 'Based on your interest in spicy food, [Restaurant Name] comes highly recommended for its fiery chicken curry.'", "restaurant_ids": ["restaurantId1", "restaurantId2"]}
    (The "criteria_summary" should be engaging and tell the user WHY these are good choices for THEM. The "restaurant_ids" MUST be from the 'All available restaurants' list provided above. Ensure the JSON is valid.)

2.  If you need more information to make a good recommendation, ask a single, clear, plain text question.
    The format MUST be:
    ASK: What type of cuisine are you in the mood for?
    (Do not include any options, just the question text after "ASK: ".)

Consider the user's history and previous answers. If no history and no previous answers, start with a general question (e.g., cuisine preference, price range).
Do not add any explanatory text before "RECOMMEND:" or "ASK:". Your entire response should start with one of these keywords.
`;
        
        return [
            {
                role: "system",
                content: [
                    { text: systemPromptText }
                ],
            },
            {
                role: "user",
                content: [
                    { text: userPromptText }
                ]
            }
        ];
    }
});


export const recommendRestaurantFlow = ai.defineFlow(
    {
        name: "recommendRestaurantFlow",
        inputSchema: z.object({
            userId: z.string().describe("The ID of the user requesting recommendations."),
            messages: z.array(
                z.object({
                    isUser: z.boolean().describe("True if the message is from the user, false if from the AI."),
                    text: z.string().describe("The text content of the message."),
                })
            ).describe("The history of messages in the conversation."),
        }),
        outputSchema: z.object({
            question: z.string().optional().describe("A new plain text question to ask the user to refine preferences."),
            recommendRestaurantId: z.array(z.string()).optional().describe("A list of recommended restaurant IDs, if a decision is made."),
            debugMessage: z.string().optional().describe("A message for debugging or simple feedback to the client."),
        }),
    },
    async (input) => {
        const { userId, messages } = input;

        // 1. Fetch user's viewed restaurant IDs and ALL restaurant data
        const viewedRestaurantIDs = await getUserViewedRestaurantIds(userId);
        const allRestaurantsData = await findAllRestaurants(); // Renamed for clarity within this scope
        
        const llmResponse = await recommendationPrompt({
            viewedRestaurantIds: viewedRestaurantIDs,
            allRestaurantsData: allRestaurantsData,
            messages: messages,
            userId: userId,
        });

        const llmOutput = llmResponse.text.trim();

        // 5. Parse LLM output and act accordingly
        if (llmOutput.startsWith("RECOMMEND:")) {
            try {
                const recommendStr = llmOutput.substring("RECOMMEND:".length).trim();
                const recommendData = JSON.parse(recommendStr);

                if (recommendData.restaurant_ids && Array.isArray(recommendData.restaurant_ids) && recommendData.restaurant_ids.length > 0) {
                    return {
                        question: recommendData.criteria_summary || "I have a recommendation for you!",
                        recommendRestaurantId: recommendData.restaurant_ids,
                        debugMessage: `LLM recommended based on: ${recommendData.criteria_summary || 'criteria not specified'}`
                    };
                } else {
                     // If LLM says RECOMMEND but doesn't provide IDs, ask a question
                    console.warn("LLM said RECOMMEND but didn't provide valid restaurant_ids:", recommendStr);
                    return {
                        question: "I was about to make a recommendation, but I need a bit more clarity. Could you specify your main preference again?",
                        recommendRestaurantId: recommendData.restaurant_ids,
                        debugMessage: `LLM RECOMMEND output was missing restaurant_ids. Output: ${recommendStr}`
                    };
                }
            } catch (error: any) {
                console.error("Error processing RECOMMEND action:", error);
                return {
                    question: "I had a little trouble processing the recommendation. What's your most important preference right now (e.g., cuisine, price)?",
                    recommendRestaurantId: [],
                    debugMessage: `Error during recommendation processing: ${error.message}. LLM Output: ${llmOutput}`
                };
            }
        } else if (llmOutput.startsWith("ASK:")) {
            try {
                const questionText = llmOutput.substring("ASK:".length).trim();
                if (!questionText) {
                    throw new Error("LLM returned ASK: with no question text.");
                }
                return {
                    question: questionText,
                    recommendRestaurantId: [],
                    debugMessage: "Generated a new question."
                };
            } catch (error: any) {
                console.error("Error processing ASK action:", error);
                return {
                    question: "I'm trying to figure out what to ask next! What's a general type of food you enjoy?",
                    recommendRestaurantId: [],
                    debugMessage: `Error parsing question from LLM: ${error.message}`
                };
            }
        } else {
            console.warn("LLM output not recognized:", llmOutput);
            return {
                question: "Let's try a different angle. Are you looking for a place for a specific occasion?",
                recommendRestaurantId: [],
                debugMessage: "LLM output was not in the expected RECOMMEND: or ASK: format."
            };
        }
    }
);

// Further Advice (adapted):
// 1.  **Firestore Data Structure:**
///     *   `/apps/foodie/users/{userId}`: Document should contain a field `viewedRestaurantIDs` (e.g., `viewedRestaurantIDs: ["id1", "id2"]`).
///     *   `/apps/foodie/restaurants/{restaurantId}`: Store comprehensive details.
/// 2.  **Prompt Engineering:** Crucial.
///     *   Refine `promptText` based on observed LLM behavior.
///     *   If the LLM struggles with the "RECOMMEND:" JSON or "ASK:" plain text format, provide few-shot examples in the prompt.
/// 3.  **History Summary for Prompt:** The current summary is basic (list of IDs). To improve LLM context, you could fetch details (cuisine, name) for a few of these `viewedRestaurantIDs`. This would involve more Firestore reads.
///     Example enhancement for history fetching (conceptual):
///     ```typescript
///     // ... inside history fetching try block
///     if (Array.isArray(viewedRestaurantIDs) && viewedRestaurantIDs.length > 0) {
///         const recentRestaurantDetailsPromises = viewedRestaurantIDs.slice(0, 3).map(id =>
///             db.collection('apps').doc('foodie').collection('restaurants').doc(id).get()
///         );
///         const recentRestaurantSnapshots = await Promise.all(recentRestaurantDetailsPromises);
///         const details = recentRestaurantSnapshots
///             .map(snap => snap.exists ? snap.data() : null)
///             .filter(Boolean)
///             .map(r => `${r.name} (${r.cuisine || 'N/A'})`)
///             .join(', ');
///         historySummary = `User has recently viewed: ${details || 'some restaurants (details unavailable)'}.`;
///     }
///     // ...
///     ```
/// 4.  **Firestore Queries:** The query for recommendations is still basic. Expand it based on the criteria the LLM can provide.
/// 5.  **Error Handling & Fallbacks:** The plain text fallbacks are in place. Consider more sophisticated recovery or guidance for the user.
/// 6.  **Security Rules:** Ensure your Firestore security rules allow your Firebase Function to read `/apps/foodie/users/{userId}` and `/apps/foodie/restaurants/**`.