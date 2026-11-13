const tbody = document.querySelector("#switches");
const status = document.querySelector("#status");

const columns = [
  "brand", "brand_country", "brand_website", "model", "switch_type",
  "actuation_force_g", "bottom_out_force_g", "pre_travel_mm",
  "total_travel_mm", "stem_material", "housing_material", "factory_lubed",
  "purchase_links",
];

function appendLink(cell, address) {
  if (!address) return;

  // Brand websites in the dataset omit https://
  let url;
  try {
    url = new URL(address.includes("://") ? address : `https://${address}`);
  } catch {
    return;
  }
  if (url.protocol !== "http:" && url.protocol !== "https:") return;

  if (cell.childNodes.length > 0) cell.append(document.createElement("br"));
  const link = document.createElement("a");
  link.href = url.href;
  link.textContent = url.hostname;
  cell.append(link);
}

async function loadSwitches() {
  status.textContent = "Loading…";

  try {
    const response = await fetch("/api/switches");
    if (!response.ok) {
      throw new Error("Could not load switches from the database.");
    }

    const switches = await response.json();
    tbody.replaceChildren();

    for (const item of switches) {
      const row = document.createElement("tr");
      for (const column of columns) {
        const cell = document.createElement("td");
        const value = item[column];

        if (column === "purchase_links") {
          for (const address of value) appendLink(cell, address);
        } else if (column === "brand_website") {
          appendLink(cell, value);
        } else if (column === "factory_lubed") {
          cell.textContent = value == null ? "" : value ? "Yes" : "No";
        } else {
          cell.textContent = value;
        }

        row.append(cell);
      }
      tbody.append(row);
    }

    status.textContent = `${switches.length} models loaded.`;
  } catch (error) {
    status.textContent = error.message;
  }
}

loadSwitches();
