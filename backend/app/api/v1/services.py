from fastapi import APIRouter
from pydantic import BaseModel
from typing import List, Optional

router = APIRouter(prefix="/services", tags=["Services Catalog"])

class ServiceSubcategoryItem(BaseModel):
    id: str
    title: str
    title_key: str
    starting_price: int
    estimated_time: str
    icon_name: str

class ServiceCategoryItem(BaseModel):
    id: str
    title: str
    title_key: str
    icon_name: str
    color_hex: str
    bg_color_hex: str
    starting_price: int
    description: str
    subcategories: List[ServiceSubcategoryItem]

CATALOG: List[ServiceCategoryItem] = [
    ServiceCategoryItem(
        id="plumber",
        title="Plumbing",
        title_key="servicePlumber",
        icon_name="plumbing",
        color_hex="#1976D2",
        bg_color_hex="#E3F2FD",
        starting_price=249,
        description="Tap repair, pipe leakages, bathroom fittings, flush tank & water lines",
        subcategories=[
            ServiceSubcategoryItem(
                id="tap_repair",
                title="Tap & Faucet Repair",
                title_key="tapFaucetRepair",
                starting_price=249,
                estimated_time="30-45 mins",
                icon_name="water_drop",
            ),
            ServiceSubcategoryItem(
                id="pipe_leakage",
                title="Pipe Leakage Repair",
                title_key="pipeLeakageRepair",
                starting_price=349,
                estimated_time="45-60 mins",
                icon_name="build",
            ),
            ServiceSubcategoryItem(
                id="drainage_cleaning",
                title="Drainage & Blockage Cleaning",
                title_key="drainageCleaning",
                starting_price=399,
                estimated_time="45-90 mins",
                icon_name="cleaning_services",
            ),
            ServiceSubcategoryItem(
                id="bathroom_fittings",
                title="Bathroom Fittings & Sanitaryware",
                title_key="bathroomFittings",
                starting_price=499,
                estimated_time="60-120 mins",
                icon_name="bathtub",
            ),
        ],
    ),
    ServiceCategoryItem(
        id="electrician",
        title="Electrician",
        title_key="serviceElectrician",
        icon_name="bolt",
        color_hex="#F57C00",
        bg_color_hex="#FFF3E0",
        starting_price=199,
        description="Fan repair, wiring, switchboards, MCB, inverter & short circuits",
        subcategories=[
            ServiceSubcategoryItem(
                id="fan_repair",
                title="Fan Repair & Installation",
                title_key="fanRepair",
                starting_price=199,
                estimated_time="30-45 mins",
                icon_name="mode_fan",
            ),
            ServiceSubcategoryItem(
                id="switchboard_socket",
                title="Switchboard & Socket Replacement",
                title_key="switchboardRepair",
                starting_price=149,
                estimated_time="20-30 mins",
                icon_name="toggle_on",
            ),
            ServiceSubcategoryItem(
                id="wiring_shortcircuit",
                title="Wiring & Short Circuit Diagnosis",
                title_key="wiringRepair",
                starting_price=349,
                estimated_time="45-90 mins",
                icon_name="electric_bolt",
            ),
            ServiceSubcategoryItem(
                id="light_fitting",
                title="LED Light & Chandelier Fitting",
                title_key="lightFitting",
                starting_price=199,
                estimated_time="30-60 mins",
                icon_name="lightbulb",
            ),
        ],
    ),
    ServiceCategoryItem(
        id="cleaning",
        title="Deep Cleaning",
        title_key="serviceCleaning",
        icon_name="cleaning_services",
        color_hex="#388E3C",
        bg_color_hex="#E8F5E9",
        starting_price=399,
        description="Home deep cleaning, water tank cleaning, bathroom sanitation & sofa shampooing",
        subcategories=[
            ServiceSubcategoryItem(
                id="tank_cleaning",
                title="Water Tank Cleaning",
                title_key="tankCleaning",
                starting_price=499,
                estimated_time="60-120 mins",
                icon_name="water",
            ),
            ServiceSubcategoryItem(
                id="bathroom_deep_clean",
                title="Bathroom Deep Sanitation",
                title_key="bathroomClean",
                starting_price=399,
                estimated_time="45-60 mins",
                icon_name="sanitizer",
            ),
            ServiceSubcategoryItem(
                id="kitchen_cleaning",
                title="Kitchen Chimney & Degreasing",
                title_key="kitchenClean",
                starting_price=599,
                estimated_time="60-90 mins",
                icon_name="kitchen",
            ),
        ],
    ),
    ServiceCategoryItem(
        id="painting",
        title="Painting",
        title_key="servicePainting",
        icon_name="format_paint",
        color_hex="#D32F2F",
        bg_color_hex="#FFEBEE",
        starting_price=499,
        description="Interior & exterior wall painting, waterproof primer & touch-ups",
        subcategories=[
            ServiceSubcategoryItem(
                id="wall_touchup",
                title="Single Wall Touch-up & Patchwork",
                title_key="wallTouchup",
                starting_price=499,
                estimated_time="60-120 mins",
                icon_name="brush",
            ),
            ServiceSubcategoryItem(
                id="waterproofing",
                title="Waterproofing & Damp Treatment",
                title_key="waterproofing",
                starting_price=899,
                estimated_time="2-4 hours",
                icon_name="shield",
            ),
        ],
    ),
    ServiceCategoryItem(
        id="appliance",
        title="Appliance Repair",
        title_key="serviceAppliance",
        icon_name="tv",
        color_hex="#7B1FA2",
        bg_color_hex="#F3E5F5",
        starting_price=299,
        description="Geyser repair, washing machine, microwave & AC service",
        subcategories=[
            ServiceSubcategoryItem(
                id="geyser_service",
                title="Water Geyser Repair",
                title_key="geyserRepair",
                starting_price=299,
                estimated_time="45-60 mins",
                icon_name="hot_tub",
            ),
            ServiceSubcategoryItem(
                id="ac_service",
                title="Air Conditioner Cleaning & Gas Check",
                title_key="acService",
                starting_price=499,
                estimated_time="60-90 mins",
                icon_name="ac_unit",
            ),
        ],
    ),
]

@router.get("/catalog", response_model=List[ServiceCategoryItem])
def get_services_catalog():
    return CATALOG
