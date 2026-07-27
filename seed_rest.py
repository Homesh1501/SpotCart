#!/usr/bin/env python3
import json
import ssl
import urllib.request
import urllib.error

PROJECT_ID = "spotcart-d21b193f"
BASE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"

# Bypass macOS Python SSL certificate store issue
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def set_document(collection, doc_id, fields):
    url = f"{BASE_URL}/{collection}/{doc_id}"
    payload = json.dumps({"fields": fields}).encode("utf-8")
    req = urllib.request.Request(url, data=payload, headers={"Content-Type": "application/json"}, method="PATCH")
    try:
        with urllib.request.urlopen(req, context=ctx) as resp:
            return resp.status == 200
    except urllib.error.HTTPError as e:
        print(f"Error {e.code}: {e.read().decode('utf-8')}")
        return False

print("🚀 Seeding Firestore via REST API...\n")

# USERS
users = [
    ("vendor_001", {
        "phoneNumber": {"stringValue": "+91 99999 55555"},
        "role": {"stringValue": "vendor"},
        "name": {"stringValue": "Spicy Fish Tacos Truck"},
        "isOnline": {"booleanValue": True},
        "location": {"geoPointValue": {"latitude": 13.0827, "longitude": 80.2707}}
    }),
    ("vendor_002", {
        "phoneNumber": {"stringValue": "+91 99999 88888"},
        "role": {"stringValue": "vendor"},
        "name": {"stringValue": "Earthy Green Fruit Stand"},
        "isOnline": {"booleanValue": True},
        "location": {"geoPointValue": {"latitude": 13.0843, "longitude": 80.2725}}
    }),
    ("vendor_003", {
        "phoneNumber": {"stringValue": "+91 88888 77777"},
        "role": {"stringValue": "vendor"},
        "name": {"stringValue": "Dosa King Cart"},
        "isOnline": {"booleanValue": True},
        "location": {"geoPointValue": {"latitude": 13.0801, "longitude": 80.2680}}
    }),
    ("vendor_004", {
        "phoneNumber": {"stringValue": "+91 77777 66666"},
        "role": {"stringValue": "vendor"},
        "name": {"stringValue": "Chai & Bonda Express"},
        "isOnline": {"booleanValue": False},
        "location": {"geoPointValue": {"latitude": 13.0865, "longitude": 80.2750}}
    }),
    ("vendor_005", {
        "phoneNumber": {"stringValue": "+91 66666 55555"},
        "role": {"stringValue": "vendor"},
        "name": {"stringValue": "Biryani Wheels"},
        "isOnline": {"booleanValue": True},
        "location": {"geoPointValue": {"latitude": 13.0790, "longitude": 80.2760}}
    }),
    ("customer_001", {
        "phoneNumber": {"stringValue": "+91 98765 43210"},
        "role": {"stringValue": "customer"},
        "name": {"stringValue": "Rahul Kumar"}
    }),
    ("customer_002", {
        "phoneNumber": {"stringValue": "+91 98765 43211"},
        "role": {"stringValue": "customer"},
        "name": {"stringValue": "Priya Sharma"}
    }),
    ("admin_001", {
        "phoneNumber": {"stringValue": "+91 99999 00000"},
        "role": {"stringValue": "admin"},
        "name": {"stringValue": "SpotCart Admin"}
    }),
]

print("📦 Writing 'users' collection...")
for doc_id, fields in users:
    ok = set_document("users", doc_id, fields)
    if ok:
        print(f"  ✅ User added: {doc_id} - {fields['name']['stringValue']}")
    else:
        print(f"  ❌ Failed: {doc_id}")

# MENU ITEMS
menu_items = [
    ("item_001", {
        "name": {"stringValue": "Caramelized Onion Burger"},
        "price": {"doubleValue": 180.0},
        "description": {"stringValue": "Juicy grass-fed beef, slow caramelized onions, brown butter glaze, and cheddar."},
        "imageUrl": {"stringValue": ""},
        "isTodaySpecial": {"booleanValue": True},
        "vendorId": {"stringValue": "vendor_001"},
        "category": {"stringValue": "Meals"},
        "isSoldOut": {"booleanValue": False}
    }),
    ("item_002", {
        "name": {"stringValue": "Earthy Sweet Potato Fries"},
        "price": {"doubleValue": 120.0},
        "description": {"stringValue": "Crispy hand-cut sweet potato fries with brown sugar dust and spicy cream."},
        "imageUrl": {"stringValue": ""},
        "isTodaySpecial": {"booleanValue": False},
        "vendorId": {"stringValue": "vendor_001"},
        "category": {"stringValue": "Snacks"},
        "isSoldOut": {"booleanValue": False}
    }),
    ("item_003", {
        "name": {"stringValue": "Spicy Street Fish Tacos"},
        "price": {"doubleValue": 160.0},
        "description": {"stringValue": "Crispy cod fillet, shredded cabbage, citrus cilantro cream, orange zest sauce."},
        "imageUrl": {"stringValue": ""},
        "isTodaySpecial": {"booleanValue": True},
        "vendorId": {"stringValue": "vendor_001"},
        "category": {"stringValue": "Meals"},
        "isSoldOut": {"booleanValue": False}
    }),
    ("item_004", {
        "name": {"stringValue": "Fresh Lime Soda"},
        "price": {"doubleValue": 50.0},
        "description": {"stringValue": "Chilled lime soda with mint and a pinch of black salt."},
        "imageUrl": {"stringValue": ""},
        "isTodaySpecial": {"booleanValue": False},
        "vendorId": {"stringValue": "vendor_001"},
        "category": {"stringValue": "Drinks"},
        "isSoldOut": {"booleanValue": False}
    }),
    ("item_005", {
        "name": {"stringValue": "Avocado Cream Dip"},
        "price": {"doubleValue": 110.0},
        "description": {"stringValue": "Smooth avocado dip with fresh cilantro and lime."},
        "imageUrl": {"stringValue": ""},
        "isTodaySpecial": {"booleanValue": False},
        "vendorId": {"stringValue": "vendor_002"},
        "category": {"stringValue": "Snacks"},
        "isSoldOut": {"booleanValue": False}
    }),
    ("item_006", {
        "name": {"stringValue": "Fresh Fruit Bowl"},
        "price": {"doubleValue": 90.0},
        "description": {"stringValue": "Seasonal cut fruits — mango, papaya, pomegranate, guava with chaat masala."},
        "imageUrl": {"stringValue": ""},
        "isTodaySpecial": {"booleanValue": True},
        "vendorId": {"stringValue": "vendor_002"},
        "category": {"stringValue": "Snacks"},
        "isSoldOut": {"booleanValue": False}
    }),
    ("item_007", {
        "name": {"stringValue": "Coconut Water"},
        "price": {"doubleValue": 40.0},
        "description": {"stringValue": "Fresh tender coconut straight from the shell."},
        "imageUrl": {"stringValue": ""},
        "isTodaySpecial": {"booleanValue": False},
        "vendorId": {"stringValue": "vendor_002"},
        "category": {"stringValue": "Drinks"},
        "isSoldOut": {"booleanValue": False}
    }),
    ("item_008", {
        "name": {"stringValue": "Masala Dosa"},
        "price": {"doubleValue": 70.0},
        "description": {"stringValue": "Crispy golden dosa filled with spiced potato masala, served with sambar and chutneys."},
        "imageUrl": {"stringValue": ""},
        "isTodaySpecial": {"booleanValue": True},
        "vendorId": {"stringValue": "vendor_003"},
        "category": {"stringValue": "Meals"},
        "isSoldOut": {"booleanValue": False}
    }),
    ("item_009", {
        "name": {"stringValue": "Ghee Roast Dosa"},
        "price": {"doubleValue": 90.0},
        "description": {"stringValue": "Paper-thin dosa roasted in pure ghee, extra crispy with a golden finish."},
        "imageUrl": {"stringValue": ""},
        "isTodaySpecial": {"booleanValue": False},
        "vendorId": {"stringValue": "vendor_003"},
        "category": {"stringValue": "Meals"},
        "isSoldOut": {"booleanValue": False}
    }),
    ("item_010", {
        "name": {"stringValue": "Onion Uttapam"},
        "price": {"doubleValue": 60.0},
        "description": {"stringValue": "Thick savory pancake topped with onions, green chillies, and tomato."},
        "imageUrl": {"stringValue": ""},
        "isTodaySpecial": {"booleanValue": False},
        "vendorId": {"stringValue": "vendor_003"},
        "category": {"stringValue": "Meals"},
        "isSoldOut": {"booleanValue": False}
    }),
    ("item_011", {
        "name": {"stringValue": "Filter Coffee"},
        "price": {"doubleValue": 30.0},
        "description": {"stringValue": "Authentic South Indian filter coffee made with freshly ground beans."},
        "imageUrl": {"stringValue": ""},
        "isTodaySpecial": {"booleanValue": True},
        "vendorId": {"stringValue": "vendor_003"},
        "category": {"stringValue": "Drinks"},
        "isSoldOut": {"booleanValue": False}
    }),
    ("item_012", {
        "name": {"stringValue": "Masala Chai"},
        "price": {"doubleValue": 20.0},
        "description": {"stringValue": "Strong ginger-cardamom tea brewed the roadside way."},
        "imageUrl": {"stringValue": ""},
        "isTodaySpecial": {"booleanValue": True},
        "vendorId": {"stringValue": "vendor_004"},
        "category": {"stringValue": "Drinks"},
        "isSoldOut": {"booleanValue": False}
    }),
    ("item_013", {
        "name": {"stringValue": "Mysore Bonda"},
        "price": {"doubleValue": 40.0},
        "description": {"stringValue": "Golden fried crispy bondas with coconut chutney."},
        "imageUrl": {"stringValue": ""},
        "isTodaySpecial": {"booleanValue": False},
        "vendorId": {"stringValue": "vendor_004"},
        "category": {"stringValue": "Snacks"},
        "isSoldOut": {"booleanValue": False}
    }),
    ("item_014", {
        "name": {"stringValue": "Bajji Platter"},
        "price": {"doubleValue": 50.0},
        "description": {"stringValue": "Mixed bajjis — onion, banana, and chilli — deep fried in gram flour batter."},
        "imageUrl": {"stringValue": ""},
        "isTodaySpecial": {"booleanValue": False},
        "vendorId": {"stringValue": "vendor_004"},
        "category": {"stringValue": "Snacks"},
        "isSoldOut": {"booleanValue": False}
    }),
    ("item_015", {
        "name": {"stringValue": "Chicken Biryani"},
        "price": {"doubleValue": 150.0},
        "description": {"stringValue": "Fragrant basmati rice layered with spiced chicken, slow-cooked dum style."},
        "imageUrl": {"stringValue": ""},
        "isTodaySpecial": {"booleanValue": True},
        "vendorId": {"stringValue": "vendor_005"},
        "category": {"stringValue": "Meals"},
        "isSoldOut": {"booleanValue": False}
    }),
    ("item_016", {
        "name": {"stringValue": "Mutton Biryani"},
        "price": {"doubleValue": 200.0},
        "description": {"stringValue": "Rich and aromatic mutton biryani with tender pieces and saffron rice."},
        "imageUrl": {"stringValue": ""},
        "isTodaySpecial": {"booleanValue": False},
        "vendorId": {"stringValue": "vendor_005"},
        "category": {"stringValue": "Meals"},
        "isSoldOut": {"booleanValue": False}
    }),
    ("item_017", {
        "name": {"stringValue": "Egg Biryani"},
        "price": {"doubleValue": 100.0},
        "description": {"stringValue": "Flavourful egg biryani with boiled eggs in masala gravy layered rice."},
        "imageUrl": {"stringValue": ""},
        "isTodaySpecial": {"booleanValue": False},
        "vendorId": {"stringValue": "vendor_005"},
        "category": {"stringValue": "Meals"},
        "isSoldOut": {"booleanValue": False}
    }),
    ("item_018", {
        "name": {"stringValue": "Raita"},
        "price": {"doubleValue": 30.0},
        "description": {"stringValue": "Cool yogurt raita with cucumber, onion, and mint."},
        "imageUrl": {"stringValue": ""},
        "isTodaySpecial": {"booleanValue": False},
        "vendorId": {"stringValue": "vendor_005"},
        "category": {"stringValue": "Snacks"},
        "isSoldOut": {"booleanValue": False}
    }),
]

print("\n📦 Writing 'menu_items' collection...")
for doc_id, fields in menu_items:
    ok = set_document("menu_items", doc_id, fields)
    if ok:
        print(f"  ✅ Menu Item added: [{fields['vendorId']['stringValue']}] {fields['name']['stringValue']} — ₹{fields['price']['doubleValue']}")
    else:
        print(f"  ❌ Failed: {doc_id}")

print("\n✨ Seeding process completed successfully!")
