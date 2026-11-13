const tbody = document.querySelector("#switches");
const status = document.querySelector("#status");

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
      const model = document.createElement("td");
      const force = document.createElement("td");

      model.textContent = item.model;
      force.textContent = item.actuation_force_g;
      row.append(model, force);
      tbody.append(row);
    }

    status.textContent = `${switches.length} models loaded.`;
  } catch (error) {
    status.textContent = error.message;
  }
}

loadSwitches();
