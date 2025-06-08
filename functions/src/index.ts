import { onCallGenkit } from "firebase-functions/https";

import { summarizeReviewFlow } from "./flow/summarizeReview";
export const summarizeReview = onCallGenkit(summarizeReviewFlow);
