import { onCallGenkit } from "firebase-functions/https";

import { summarizeDishReviewFlow } from "./flow/summarizeDishReview";
export const summarizeDishReview = onCallGenkit(summarizeDishReviewFlow);

import { summarizeRestaurantReviewFlow } from "./flow/summarizeRestaurantReview";
export const summarizeRestaurantReview = onCallGenkit(summarizeRestaurantReviewFlow);

import { recommendRestaurantFlow } from "./flow/recommendRestaurant";
export const recommendRestaurant = onCallGenkit(recommendRestaurantFlow);
