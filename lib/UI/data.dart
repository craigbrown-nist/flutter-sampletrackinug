//  can be database calls?

const placeOptions = ["Confinement", "GuideHall", "Lab", "Other"];

const locationOptionsConf = [
  "BT1",
  "BT2",
  "BT4",
  "BT5",
  "BT7",
  "BT8",
  "MACS",
  ""
];
const bt1locid = [
  "On Beam",
  "Samp. Changer",
  "Bank 16",
  "Bank 16b",
  "Black Cab",
  ""
];
const bt2locid = ["On Beam", "Beige Cab", ""];
const bt4locid = ["On Beam", "Grey Cab", ""];
const bt5locid = ["On Beam", "Cabinet", ""];
const bt7locid = ["On Beam", "Cream Cab", "Bank 2", ""];
const bt8locid = ["On Beam", "Workspace", ""];
const macslocid = ["On Beam", "Cabinet", ""];

const locationOptionsGuide = [
  "NSE",
  "HFBS",
  "DCS",
  "NG6-Image",
  "nSOFT",
  "PGAA",
  "CNDP",
  "LAUE",
  "PHADES",
  "MAGik",
  "PBR",
  "CANDOR",
  "NG7-REFL",
  "NG7-SANS",
  "VSANS",
  "NGb-SANS",
  "SPINS",
  "Polar",
  "East",
  "North",
  ""
];

const guideINSTlocid = ["On Beam", "Cabinet", ""];

const guidePOLARlocid = ["On Beam", "Cabinet", "Bank 26", ""];

const guideSPINSlocid = [
  "On Beam",
  "Bank 13",
  "Bank 15",
  "Bank 16a",
  "Bank 19",
  "Bank 17",
  ""
];
const guideEASTlocid = ["Bank 4", "Bank 7", "Bank 18", ""];
const guideNORTHlocid = [
  "Bank 20",
  "Bank 21",
  "Bank 22",
  "Bank 23",
  "Bank 24",
  "Bank 25",
  "sample env",
  ""
];

const bankdrawer = ["1", "2", "3", "4", "5", "6", "7", "8", "9", ""];
const cabinetdrawer = ["1", "2", ""];
const otherdrawer = ["1", ""];

const locationOptionsLab = [
  "A115",
  "A117",
  "A127",
  "A132",
  "B142",
  "B147",
  "E131",
  "E132",
  "E133",
  "E134",
  "E135",
  "E136",
  "E137",
  "E138",
  ""
];

const a115locid = ["Stored", "Waste", ""];
const a117locid = ["Freezer", "Freezer4-Left", "Freezer4-Right", ""];
const a127locid = ["Stored", "Waste", ""];
const a132locid = ["Stored", "Waste", ""];
const b147locid = ["Stored", "Waste", "Ready to Unload", "Decision needed", ""];
const b142locid = ["Glovebox", "Drawer", "Waste", ""];
const e131locid = ["Glovebox", "Argon box", "Drawer", "Freezer", "Waste", ""];
const e132locid = ["Stored", "Waste", "Freezer", ""];
const e133locid = ["Stored", "Waste", ""];
const e134locid = [
  "Stored",
  "Waste",
  "Freezer",
  "Fridge-Left",
  "Fridge-Right",
  ""
];
const e135locid = [
  "Glovebox-wet",
  "Waste",
  "Freezer-Left",
  "Freezer-Right",
  ""
];
const e136locid = ["Stored", "Waste", ""];
const e137locid = ["Stored", "Waste", ""];
const e138locid = ["Stored", "Waste", "Freezer-Left", "Freezer-Right", ""];

const drawer4 = ["1", "2", "3", "4", ""];
const drawer5 = ["1", "2", "3", "4", "5", ""];
const drawer6 = ["1", "2", "3", "4", "5", "6", ""];

const locationOptionsOther = ["HP_Clear", "Shipped back", "Waste", ""];

const hplocid = ["dropped_off", "Cabinet", ""]; //no drawer options
const shiplocid = ["UPS", "Fedex", "Other", ""]; //no drawer options
