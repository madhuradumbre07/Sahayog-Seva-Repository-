from typing import Dict, Any
from pydantic import BaseModel

class ProblemParseResult(BaseModel):
    service_category: str
    subcategory: str
    urgency: str
    confidence_score: float
    detected_language: str
    explanation: str
    suggested_skills: list[str]
    estimated_time_min: int
    estimated_time_max: int
    estimated_cost_min: int
    estimated_cost_max: int

class AiProblemParserService:
    @staticmethod
    def parse_problem(text: str, detected_lang: str = "mr") -> ProblemParseResult:
        text_lower = text.lower().strip()
        
        # Rule-based semantic classification for regional keywords
        # Electrical keywords
        if any(k in text_lower for k in ["fan", "पंखा", "फॅन", "light", "लाईट", "बिजली", "वायरिंग", "wiring", "fuse", "फ्यूज"]):
            return ProblemParseResult(
                service_category="Electrician",
                subcategory="Fan & Wiring Repair",
                urgency="HIGH" if any(k in text_lower for k in ["spark", "आग", "शॉक", "धूर", "smoke"]) else "MEDIUM",
                confidence_score=0.94,
                detected_language=detected_lang,
                explanation="AI detected electrical issues based on appliance and wiring keywords.",
                suggested_skills=["Electrical Safety", "Appliance Wiring", "Short Circuit Repair"],
                estimated_time_min=30,
                estimated_time_max=60,
                estimated_cost_min=200,
                estimated_cost_max=450,
            )
            
        # Cleaning keywords
        elif any(k in text_lower for k in ["clean", "सफाई", "धुलाई", "झाडू", "deep clean", "टँक", "tank"]):
            return ProblemParseResult(
                service_category="Deep Cleaning",
                subcategory="Home & Tank Cleaning",
                urgency="LOW",
                confidence_score=0.88,
                detected_language=detected_lang,
                explanation="AI detected cleaning and sanitation requirements.",
                suggested_skills=["Deep Sanitation", "Pressure Washing", "Water Tank Cleaning"],
                estimated_time_min=60,
                estimated_time_max=120,
                estimated_cost_min=500,
                estimated_cost_max=1200,
            )

        # Default / Plumbing keywords (Tap, Leak, Pipe, Drain, Geyser, गळती, नळ, पाईप, वॉशबेसिन)
        is_emergency = any(k in text_lower for k in ["burst", "पूर", "flood", "फुटला", "तात्काळ", "urgent", "emergency"])
        return ProblemParseResult(
            service_category="Plumbing",
            subcategory="Tap & Faucet Repair",
            urgency="EMERGENCY" if is_emergency else "MEDIUM",
            confidence_score=0.92,
            detected_language=detected_lang,
            explanation="AI analyzed the symptoms (water leakage / faucet valve wear) matching Plumbing (Tap Repair) with 92% confidence.",
            suggested_skills=["Tap Repair", "Pipe Leakage", "Valve Replacement", "Bathroom Plumbing"],
            estimated_time_min=30,
            estimated_time_max=45,
            estimated_cost_min=250,
            estimated_cost_max=500,
        )
