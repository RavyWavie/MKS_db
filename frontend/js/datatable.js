const tbody = document.querySelector("#switches");
const status = document.querySelector("#status");
const form = document.querySelector("#filter-form");
const search = document.querySelector("#search");
const attribute = document.querySelector("#attribute");
const csvDownload = document.querySelector("#download-csv");
const jsonDownload = document.querySelector("#download-json");
let activeRequest;

const columns = [
  "brand", "brand_country", "brand_website", "model", "switch_type",
  "actuation_force_g", "bottom_out_force_g", "pre_travel_mm",
  "total_travel_mm", "stem_material", "housing_material", "factory_lubed",
  "purchase_links",
];

function csvValue(value) {
  if (value == null) return "";
  if (typeof value === "boolean") return value ? "t" : "f";
  return `"${String(value).replaceAll('"', '""')}"`;
}

function buildCSV(switches) {
  const fields = columns.filter(column => column !== "purchase_links");
  const rows = [[...fields, "purchase_url"].join(",")];

  for (const item of switches) {
    const links = item.purchase_links.length ? item.purchase_links : [null];
    for (const link of links) {
      rows.push([...fields.map(field => item[field]), link].map(csvValue).join(","));
    }
  }

  return rows.join("\r\n") + "\r\n";
}

function setDownload(link, content, type) {
  if (link.hasAttribute("href")) URL.revokeObjectURL(link.href);
  link.href = URL.createObjectURL(new Blob([content], { type }));
}

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
  activeRequest?.abort();
  const controller = new AbortController();
  activeRequest = controller;
  status.textContent = "Loading…";

  try {
    const params = new URLSearchParams({ search: search.value, attribute: attribute.value });
    const response = await fetch(`/api/switches?${params}`, { signal: controller.signal });
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
    setDownload(csvDownload, buildCSV(switches), "text/csv;charset=utf-8");
    setDownload(jsonDownload, JSON.stringify(switches, null, 2), "application/json");
    status.textContent = switches.length === 0 ? "No matching models." : "";
  } catch (error) {
    if (error.name === "AbortError") return;
    status.textContent = error.message;
  }
}

form.addEventListener("submit", (event) => {
  event.preventDefault();
  loadSwitches();
});

form.addEventListener("reset", () => {
  search.value = "";
  attribute.value = "all";
  loadSwitches();
});

search.addEventListener("input", () => {
  if (search.value === "") loadSwitches();
});

loadSwitches();
