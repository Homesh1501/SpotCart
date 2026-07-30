// seed_firestore.js
// Run with: node seed_firestore.js
// Seeds the Firestore database with initial vendor users and menu items

const { initializeApp, applicationDefault, cert } = require("firebase-admin/app");
const { getFirestore, GeoPoint, FieldValue } = require("firebase-admin/firestore");

// Initialize with application default credentials
initializeApp({
  projectId: "spotcart-d21b193f",
});

const db = getFirestore();

async function seedDatabase() {
  console.log("🚀 Starting SpotCart Firestore seed...\n");

  // ═══════════════════════════════════════════
  // USERS COLLECTION
  // ═══════════════════════════════════════════
  const users = [
    {
      id: "vendor_001",
      phoneNumber: "+91 99999 55555",
      role: "vendor",
      name: "Spicy Fish Tacos Truck",
      isOnline: true,
      location: new GeoPoint(13.0827, 80.2707), // Chennai
      lastUpdated: FieldValue.serverTimestamp(),
    },
    {
      id: "vendor_002",
      phoneNumber: "+91 99999 88888",
      role: "vendor",
      name: "Earthy Green Fruit Stand",
      isOnline: true,
      location: new GeoPoint(13.0843, 80.2725), // Chennai nearby
      lastUpdated: FieldValue.serverTimestamp(),
    },
    {
      id: "vendor_003",
      phoneNumber: "+91 88888 77777",
      role: "vendor",
      name: "Dosa King Cart",
      isOnline: true,
      location: new GeoPoint(13.0801, 80.2680), // Chennai south
      lastUpdated: FieldValue.serverTimestamp(),
    },
    {
      id: "vendor_004",
      phoneNumber: "+91 77777 66666",
      role: "vendor",
      name: "Chai & Bonda Express",
      isOnline: false,
      location: new GeoPoint(13.0865, 80.2750),
      lastUpdated: FieldValue.serverTimestamp(),
    },
    {
      id: "vendor_005",
      phoneNumber: "+91 66666 55555",
      role: "vendor",
      name: "Biryani Wheels",
      isOnline: true,
      location: new GeoPoint(13.0790, 80.2760), // Chennai east
      lastUpdated: FieldValue.serverTimestamp(),
    },
    {
      id: "customer_001",
      phoneNumber: "+91 98765 43210",
      role: "customer",
      name: "Rahul Kumar",
      isOnline: null,
      location: null,
      lastUpdated: FieldValue.serverTimestamp(),
    },
    {
      id: "customer_002",
      phoneNumber: "+91 98765 43211",
      role: "customer",
      name: "Priya Sharma",
      isOnline: null,
      location: null,
      lastUpdated: FieldValue.serverTimestamp(),
    },
    {
      id: "admin_001",
      phoneNumber: "+91 99999 00000",
      role: "admin",
      name: "SpotCart Admin",
      isOnline: null,
      location: null,
      lastUpdated: FieldValue.serverTimestamp(),
    },
  ];

  console.log("📦 Seeding users collection...");
  for (const user of users) {
    const { id, ...data } = user;
    await db.collection("users").doc(id).set(data);
    console.log(`   ✅ ${data.role}: ${data.name} (${id})`);
  }

  // ═══════════════════════════════════════════
  // MENU_ITEMS COLLECTION
  // ═══════════════════════════════════════════
  const menuItems = [
    // --- Vendor 001: Spicy Fish Tacos Truck ---
    {
      id: "item_001",
      name: "Caramelized Onion Burger",
      price: 180.0,
      description: "Juicy grass-fed beef, slow caramelized onions, brown butter glaze, and cheddar.",
      imageUrl: "",
      isTodaySpecial: true,
      vendorId: "vendor_001",
      category: "Meals",
      isSoldOut: false,
    },
    {
      id: "item_002",
      name: "Earthy Sweet Potato Fries",
      price: 120.0,
      description: "Crispy hand-cut sweet potato fries with brown sugar dust and spicy cream.",
      imageUrl: "",
      isTodaySpecial: false,
      vendorId: "vendor_001",
      category: "Snacks",
      isSoldOut: false,
    },
    {
      id: "item_003",
      name: "Spicy Street Fish Tacos",
      price: 160.0,
      description: "Crispy cod fillet, shredded cabbage, citrus cilantro cream, orange zest sauce.",
      imageUrl: "",
      isTodaySpecial: true,
      vendorId: "vendor_001",
      category: "Meals",
      isSoldOut: false,
    },
    {
      id: "item_004",
      name: "Fresh Lime Soda",
      price: 50.0,
      description: "Chilled lime soda with mint and a pinch of black salt.",
      imageUrl: "",
      isTodaySpecial: false,
      vendorId: "vendor_001",
      category: "Drinks",
      isSoldOut: false,
    },

    // --- Vendor 002: Earthy Green Fruit Stand ---
    {
      id: "item_005",
      name: "Avocado Cream Dip",
      price: 110.0,
      description: "Smooth avocado dip with fresh cilantro and lime.",
      imageUrl: "",
      isTodaySpecial: false,
      vendorId: "vendor_002",
      category: "Snacks",
      isSoldOut: false,
    },
    {
      id: "item_006",
      name: "Fresh Fruit Bowl",
      price: 90.0,
      description: "Seasonal cut fruits — mango, papaya, pomegranate, guava with chaat masala.",
      imageUrl: "",
      isTodaySpecial: true,
      vendorId: "vendor_002",
      category: "Snacks",
      isSoldOut: false,
    },
    {
      id: "item_007",
      name: "Coconut Water",
      price: 40.0,
      description: "Fresh tender coconut straight from the shell.",
      imageUrl: "",
      isTodaySpecial: false,
      vendorId: "vendor_002",
      category: "Drinks",
      isSoldOut: false,
    },

    // --- Vendor 003: Dosa King Cart ---
    {
      id: "item_008",
      name: "Masala Dosa",
      price: 70.0,
      description: "Crispy golden dosa filled with spiced potato masala, served with sambar and chutneys.",
      imageUrl: "",
      isTodaySpecial: true,
      vendorId: "vendor_003",
      category: "Meals",
      isSoldOut: false,
    },
    {
      id: "item_009",
      name: "Ghee Roast Dosa",
      price: 90.0,
      description: "Paper-thin dosa roasted in pure ghee, extra crispy with a golden finish.",
      imageUrl: "",
      isTodaySpecial: false,
      vendorId: "vendor_003",
      category: "Meals",
      isSoldOut: false,
    },
    {
      id: "item_010",
      name: "Onion Uttapam",
      price: 60.0,
      description: "Thick savory pancake topped with onions, green chillies, and tomato.",
      imageUrl: "",
      isTodaySpecial: false,
      vendorId: "vendor_003",
      category: "Meals",
      isSoldOut: false,
    },
    {
      id: "item_011",
      name: "Filter Coffee",
      price: 30.0,
      description: "Authentic South Indian filter coffee made with freshly ground beans.",
      imageUrl: "",
      isTodaySpecial: true,
      vendorId: "vendor_003",
      category: "Drinks",
      isSoldOut: false,
    },

    // --- Vendor 004: Chai & Bonda Express ---
    {
      id: "item_012",
      name: "Masala Chai",
      price: 20.0,
      description: "Strong ginger-cardamom tea brewed the roadside way.",
      imageUrl: "",
      isTodaySpecial: true,
      vendorId: "vendor_004",
      category: "Drinks",
      isSoldOut: false,
    },
    {
      id: "item_013",
      name: "Mysore Bonda",
      price: 40.0,
      description: "Golden fried crispy bondas with coconut chutney.",
      imageUrl: "",
      isTodaySpecial: false,
      vendorId: "vendor_004",
      category: "Snacks",
      isSoldOut: false,
    },
    {
      id: "item_014",
      name: "Bajji Platter",
      price: 50.0,
      description: "Mixed bajjis — onion, banana, and chilli — deep fried in gram flour batter.",
      imageUrl: "",
      isTodaySpecial: false,
      vendorId: "vendor_004",
      category: "Snacks",
      isSoldOut: false,
    },

    // --- Vendor 005: Biryani Wheels ---
    {
      id: "item_015",
      name: "Chicken Biryani",
      price: 150.0,
      description: "Fragrant basmati rice layered with spiced chicken, slow-cooked dum style.",
      imageUrl: "",
      isTodaySpecial: true,
      vendorId: "vendor_005",
      category: "Meals",
      isSoldOut: false,
    },
    {
      id: "item_016",
      name: "Mutton Biryani",
      price: 200.0,
      description: "Rich and aromatic mutton biryani with tender pieces and saffron rice.",
      imageUrl: "",
      isTodaySpecial: false,
      vendorId: "vendor_005",
      category: "Meals",
      isSoldOut: false,
    },
    {
      id: "item_017",
      name: "Egg Biryani",
      price: 100.0,
      description: "Flavourful egg biryani with boiled eggs in masala gravy layered rice.",
      imageUrl: "",
      isTodaySpecial: false,
      vendorId: "vendor_005",
      category: "Meals",
      isSoldOut: false,
    },
    {
      id: "item_018",
      name: "Raita",
      price: 30.0,
      description: "Cool yogurt raita with cucumber, onion, and mint.",
      imageUrl: "",
      isTodaySpecial: false,
      vendorId: "vendor_005",
      category: "Snacks",
      isSoldOut: false,
    },
  ];

  console.log("\n📦 Seeding menu_items collection...");
  for (const item of menuItems) {
    const { id, ...data } = item;
    await db.collection("menu_items").doc(id).set(data);
    console.log(`   ✅ [${data.vendorId}] ${data.name} — ₹${data.price}`);
  }

  console.log("\n════════════════════════════════════════");
  console.log("✅ Database seeded successfully!");
  console.log(`   • ${users.length} users (${users.filter(u => u.role === 'vendor').length} vendors, ${users.filter(u => u.role === 'customer').length} customers, ${users.filter(u => u.role === 'admin').length} admin)`);
  console.log(`   • ${menuItems.length} menu items`);
  console.log("════════════════════════════════════════");
  console.log("\n🔗 View in console: https://console.firebase.google.com/project/spotcart-d21b193f/firestore/databases/-default-/data");

  process.exit(0);
}

seedDatabase().catch((error) => {
  console.error("❌ Seed failed:", error);
  process.exit(1);
});
