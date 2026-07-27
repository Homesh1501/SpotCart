#!/bin/bash
# seed_firestore.sh
# Seeds the Firestore database with initial SpotCart data using Firebase CLI
# Usage: bash seed_firestore.sh

PROJECT="spotcart-d21b193f"

echo "🚀 Starting SpotCart Firestore seed..."
echo ""

# ═══════════════════════════════════════════
# Helper function to create/set a document
# ═══════════════════════════════════════════
set_doc() {
  local collection="$1"
  local doc_id="$2"
  local data="$3"
  
  curl -s -X PATCH \
    "https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents/${collection}/${doc_id}?updateMask.fieldPaths=$(echo "$4")" \
    -H "Authorization: Bearer $(firebase login:ci --no-localhost 2>/dev/null || echo '')" \
    -H "Content-Type: application/json" \
    -d "$data" > /dev/null 2>&1
}

# Use firebase CLI's emulator:export alternative — write via REST with oauth token
TOKEN=$(firebase --project "$PROJECT" login:ci --no-localhost 2>/dev/null || echo "")

echo "📦 Seeding users collection..."

# We'll write a Node script that uses firebase-admin with Firebase CLI credentials
node -e "
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, GeoPoint, FieldValue } = require('firebase-admin/firestore');

process.env.FIRESTORE_EMULATOR_HOST = '';

// Use the Application Default Credentials from gcloud/firebase
const app = initializeApp({ projectId: 'spotcart-d21b193f' });
const db = getFirestore();

async function seed() {
  // Users
  const users = [
    { id: 'vendor_001', data: { phoneNumber: '+91 99999 55555', role: 'vendor', name: 'Spicy Fish Tacos Truck', isOnline: true, location: new GeoPoint(13.0827, 80.2707), lastUpdated: FieldValue.serverTimestamp() }},
    { id: 'vendor_002', data: { phoneNumber: '+91 99999 88888', role: 'vendor', name: 'Earthy Green Fruit Stand', isOnline: true, location: new GeoPoint(13.0843, 80.2725), lastUpdated: FieldValue.serverTimestamp() }},
    { id: 'vendor_003', data: { phoneNumber: '+91 88888 77777', role: 'vendor', name: 'Dosa King Cart', isOnline: true, location: new GeoPoint(13.0801, 80.2680), lastUpdated: FieldValue.serverTimestamp() }},
    { id: 'vendor_004', data: { phoneNumber: '+91 77777 66666', role: 'vendor', name: 'Chai & Bonda Express', isOnline: false, location: new GeoPoint(13.0865, 80.2750), lastUpdated: FieldValue.serverTimestamp() }},
    { id: 'vendor_005', data: { phoneNumber: '+91 66666 55555', role: 'vendor', name: 'Biryani Wheels', isOnline: true, location: new GeoPoint(13.0790, 80.2760), lastUpdated: FieldValue.serverTimestamp() }},
    { id: 'customer_001', data: { phoneNumber: '+91 98765 43210', role: 'customer', name: 'Rahul Kumar', isOnline: null, location: null, lastUpdated: FieldValue.serverTimestamp() }},
    { id: 'customer_002', data: { phoneNumber: '+91 98765 43211', role: 'customer', name: 'Priya Sharma', isOnline: null, location: null, lastUpdated: FieldValue.serverTimestamp() }},
    { id: 'admin_001', data: { phoneNumber: '+91 99999 00000', role: 'admin', name: 'SpotCart Admin', isOnline: null, location: null, lastUpdated: FieldValue.serverTimestamp() }},
  ];
  for (const u of users) { await db.collection('users').doc(u.id).set(u.data); console.log('  ✅ ' + u.data.role + ': ' + u.data.name); }
  
  // Menu Items  
  const items = [
    { id: 'item_001', data: { name: 'Caramelized Onion Burger', price: 180, description: 'Juicy grass-fed beef, slow caramelized onions, brown butter glaze, and cheddar.', imageUrl: '', isTodaySpecial: true, vendorId: 'vendor_001', category: 'Meals', isSoldOut: false }},
    { id: 'item_002', data: { name: 'Earthy Sweet Potato Fries', price: 120, description: 'Crispy hand-cut sweet potato fries with brown sugar dust and spicy cream.', imageUrl: '', isTodaySpecial: false, vendorId: 'vendor_001', category: 'Snacks', isSoldOut: false }},
    { id: 'item_003', data: { name: 'Spicy Street Fish Tacos', price: 160, description: 'Crispy cod fillet, shredded cabbage, citrus cilantro cream, orange zest sauce.', imageUrl: '', isTodaySpecial: true, vendorId: 'vendor_001', category: 'Meals', isSoldOut: false }},
    { id: 'item_004', data: { name: 'Fresh Lime Soda', price: 50, description: 'Chilled lime soda with mint and a pinch of black salt.', imageUrl: '', isTodaySpecial: false, vendorId: 'vendor_001', category: 'Drinks', isSoldOut: false }},
    { id: 'item_005', data: { name: 'Avocado Cream Dip', price: 110, description: 'Smooth avocado dip with fresh cilantro and lime.', imageUrl: '', isTodaySpecial: false, vendorId: 'vendor_002', category: 'Snacks', isSoldOut: false }},
    { id: 'item_006', data: { name: 'Fresh Fruit Bowl', price: 90, description: 'Seasonal cut fruits — mango, papaya, pomegranate, guava with chaat masala.', imageUrl: '', isTodaySpecial: true, vendorId: 'vendor_002', category: 'Snacks', isSoldOut: false }},
    { id: 'item_007', data: { name: 'Coconut Water', price: 40, description: 'Fresh tender coconut straight from the shell.', imageUrl: '', isTodaySpecial: false, vendorId: 'vendor_002', category: 'Drinks', isSoldOut: false }},
    { id: 'item_008', data: { name: 'Masala Dosa', price: 70, description: 'Crispy golden dosa filled with spiced potato masala, served with sambar and chutneys.', imageUrl: '', isTodaySpecial: true, vendorId: 'vendor_003', category: 'Meals', isSoldOut: false }},
    { id: 'item_009', data: { name: 'Ghee Roast Dosa', price: 90, description: 'Paper-thin dosa roasted in pure ghee, extra crispy with a golden finish.', imageUrl: '', isTodaySpecial: false, vendorId: 'vendor_003', category: 'Meals', isSoldOut: false }},
    { id: 'item_010', data: { name: 'Onion Uttapam', price: 60, description: 'Thick savory pancake topped with onions, green chillies, and tomato.', imageUrl: '', isTodaySpecial: false, vendorId: 'vendor_003', category: 'Meals', isSoldOut: false }},
    { id: 'item_011', data: { name: 'Filter Coffee', price: 30, description: 'Authentic South Indian filter coffee made with freshly ground beans.', imageUrl: '', isTodaySpecial: true, vendorId: 'vendor_003', category: 'Drinks', isSoldOut: false }},
    { id: 'item_012', data: { name: 'Masala Chai', price: 20, description: 'Strong ginger-cardamom tea brewed the roadside way.', imageUrl: '', isTodaySpecial: true, vendorId: 'vendor_004', category: 'Drinks', isSoldOut: false }},
    { id: 'item_013', data: { name: 'Mysore Bonda', price: 40, description: 'Golden fried crispy bondas with coconut chutney.', imageUrl: '', isTodaySpecial: false, vendorId: 'vendor_004', category: 'Snacks', isSoldOut: false }},
    { id: 'item_014', data: { name: 'Bajji Platter', price: 50, description: 'Mixed bajjis — onion, banana, and chilli — deep fried in gram flour batter.', imageUrl: '', isTodaySpecial: false, vendorId: 'vendor_004', category: 'Snacks', isSoldOut: false }},
    { id: 'item_015', data: { name: 'Chicken Biryani', price: 150, description: 'Fragrant basmati rice layered with spiced chicken, slow-cooked dum style.', imageUrl: '', isTodaySpecial: true, vendorId: 'vendor_005', category: 'Meals', isSoldOut: false }},
    { id: 'item_016', data: { name: 'Mutton Biryani', price: 200, description: 'Rich and aromatic mutton biryani with tender pieces and saffron rice.', imageUrl: '', isTodaySpecial: false, vendorId: 'vendor_005', category: 'Meals', isSoldOut: false }},
    { id: 'item_017', data: { name: 'Egg Biryani', price: 100, description: 'Flavourful egg biryani with boiled eggs in masala gravy layered rice.', imageUrl: '', isTodaySpecial: false, vendorId: 'vendor_005', category: 'Meals', isSoldOut: false }},
    { id: 'item_018', data: { name: 'Raita', price: 30, description: 'Cool yogurt raita with cucumber, onion, and mint.', imageUrl: '', isTodaySpecial: false, vendorId: 'vendor_005', category: 'Snacks', isSoldOut: false }},
  ];
  for (const i of items) { await db.collection('menu_items').doc(i.id).set(i.data); console.log('  ✅ [' + i.data.vendorId + '] ' + i.data.name + ' — ₹' + i.data.price); }

  console.log('\n✅ Database seeded: 8 users + 18 menu items');
  console.log('🔗 https://console.firebase.google.com/project/spotcart-d21b193f/firestore/databases/-default-/data');
  process.exit(0);
}
seed().catch(e => { console.error('❌', e.message); process.exit(1); });
"
