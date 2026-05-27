setwd('C:/Users/Khuram Afzal/Desktop/EC CENSUS')
json_raw <- readLines('dashboard_data.json', warn=FALSE)
json_str  <- paste(json_raw, collapse='\n')

html <- sprintf('<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>EC Census Punjab Dashboard</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:"Segoe UI",Arial,sans-serif;background:#f0f4f8;color:#1a2636}
.header{background:linear-gradient(135deg,#1a3a5c 0%%,#0e6e4e 100%%);color:#fff;padding:24px 32px;display:flex;align-items:center;gap:20px}
.header-logo{font-size:42px}
.header-text h1{font-size:22px;font-weight:700;letter-spacing:.5px}
.header-text p{font-size:13px;opacity:.85;margin-top:4px}
.filters{background:#fff;padding:20px 32px;display:flex;flex-wrap:wrap;gap:18px;align-items:flex-end;box-shadow:0 2px 8px rgba(0,0,0,.08)}
.filter-group{display:flex;flex-direction:column;gap:6px;min-width:200px}
.filter-group label{font-size:12px;font-weight:600;color:#1a3a5c;text-transform:uppercase;letter-spacing:.4px}
.filter-group select{padding:10px 14px;border:1.5px solid #c5d5e8;border-radius:8px;font-size:14px;background:#fff;color:#1a2636;cursor:pointer;outline:none;appearance:none;background-image:url("data:image/svg+xml;charset=utf-8,%%3Csvg xmlns=\'http://www.w3.org/2000/svg\' width=\'12\' height=\'12\' viewBox=\'0 0 12 12\'%%3E%%3Cpath fill=\'%%231a3a5c\' d=\'M6 8L1 3h10z\'/ %%3E%%3C/svg%%3E");background-repeat:no-repeat;background-position:right 12px center;padding-right:32px}
.filter-group select:focus{border-color:#0e6e4e;box-shadow:0 0 0 3px rgba(14,110,78,.12)}
.btn-reset{padding:10px 22px;background:#1a3a5c;color:#fff;border:none;border-radius:8px;font-size:14px;font-weight:600;cursor:pointer;transition:background .2s}
.btn-reset:hover{background:#0e6e4e}
.content{padding:24px 32px;display:flex;flex-direction:column;gap:24px}
.summary-cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:16px}
.card{background:#fff;border-radius:12px;padding:20px;box-shadow:0 2px 8px rgba(0,0,0,.07);display:flex;flex-direction:column;gap:8px}
.card-icon{font-size:28px}
.card-label{font-size:12px;font-weight:600;color:#6b82a0;text-transform:uppercase;letter-spacing:.4px}
.card-value{font-size:28px;font-weight:700;color:#1a3a5c}
.card-sub{font-size:12px;color:#6b82a0}
.card.green .card-value{color:#0e6e4e}
.card.amber .card-value{color:#b8650a}
.card.red .card-value{color:#b81a1a}
.tabs{display:flex;gap:4px;border-bottom:2px solid #c5d5e8}
.tab{padding:10px 20px;font-size:13px;font-weight:600;color:#6b82a0;cursor:pointer;border-radius:8px 8px 0 0;transition:all .2s;border:2px solid transparent;border-bottom:none;margin-bottom:-2px}
.tab.active{color:#1a3a5c;background:#fff;border-color:#c5d5e8;border-bottom-color:#fff}
.tab:hover:not(.active){color:#1a3a5c;background:#e8f0fa}
.tab-content{display:none}
.tab-content.active{display:block}
.section{background:#fff;border-radius:12px;padding:24px;box-shadow:0 2px 8px rgba(0,0,0,.07)}
.section h3{font-size:16px;font-weight:700;color:#1a3a5c;margin-bottom:4px}
.section .subtitle{font-size:12px;color:#6b82a0;margin-bottom:20px}
.chart-wrap{position:relative;width:100%%;height:380px}
.chart-wrap canvas{max-height:380px}
.grid-2{display:grid;grid-template-columns:1fr 1fr;gap:20px}
@media(max-width:800px){.grid-2{grid-template-columns:1fr}}
.note{font-size:11px;color:#999;margin-top:12px;font-style:italic}
.no-data{display:flex;align-items:center;justify-content:center;height:200px;color:#aaa;font-size:16px}
.district-tag{display:inline-block;background:#e8f0fa;color:#1a3a5c;border-radius:20px;padding:3px 12px;font-size:12px;font-weight:600;margin-bottom:16px}
</style>
</head>
<body>

<div class="header">
  <div class="header-logo">&#127981;</div>
  <div class="header-text">
    <h1>Punjab Economic Census &mdash; Establishments Dashboard</h1>
    <p>District-level data on establishments, workforce, unit types, and employment categories across Punjab</p>
  </div>
</div>

<div class="filters">
  <div class="filter-group">
    <label>Division</label>
    <select id="sel-division" onchange="onDivisionChange()">
      <option value="">All Divisions</option>
    </select>
  </div>
  <div class="filter-group">
    <label>District</label>
    <select id="sel-district" onchange="onDistrictChange()">
      <option value="">Select District</option>
    </select>
  </div>
  <div class="filter-group">
    <label>Tehsil</label>
    <select id="sel-tehsil" onchange="renderAll()">
      <option value="">All Tehsils</option>
    </select>
  </div>
  <button class="btn-reset" onclick="resetFilters()">&#x21ba; Reset</button>
</div>

<div class="content">
  <div class="summary-cards" id="summary-cards"></div>
  <div>
    <div class="tabs">
      <div class="tab active" onclick="switchTab(0)">&#128200; PSIC Sectors</div>
      <div class="tab" onclick="switchTab(1)">&#127970; Unit Types</div>
      <div class="tab" onclick="switchTab(2)">&#128101; Employment Size</div>
      <div class="tab" onclick="switchTab(3)">&#9989; Unit &times; Employment</div>
    </div>
    <div style="background:#fff;border-radius:0 12px 12px 12px;box-shadow:0 2px 8px rgba(0,0,0,.07)">
      <div class="tab-content active" id="tab0" style="padding:24px">
        <h3>PSIC Sector-wise Establishments &amp; Workforce</h3>
        <p class="subtitle">Table 1 &mdash; Number of establishments and workforce by major economic sector (PSIC classification)</p>
        <div class="grid-2">
          <div class="section">
            <h3 style="font-size:14px">Establishments by Sector</h3>
            <div class="chart-wrap"><canvas id="chart-psic-estab"></canvas></div>
          </div>
          <div class="section">
            <h3 style="font-size:14px">Workforce by Sector</h3>
            <div class="chart-wrap"><canvas id="chart-psic-workforce"></canvas></div>
          </div>
        </div>
      </div>
      <div class="tab-content" id="tab1" style="padding:24px">
        <h3>Unit Type-wise Establishments &amp; Workforce</h3>
        <p class="subtitle">Table 2 &mdash; Establishments and workforce distributed by business unit type</p>
        <div class="grid-2">
          <div class="section">
            <h3 style="font-size:14px">Establishments by Unit Type</h3>
            <div class="chart-wrap"><canvas id="chart-ut-estab"></canvas></div>
          </div>
          <div class="section">
            <h3 style="font-size:14px">Workforce by Unit Type</h3>
            <div class="chart-wrap"><canvas id="chart-ut-workforce"></canvas></div>
          </div>
        </div>
      </div>
      <div class="tab-content" id="tab2" style="padding:24px">
        <h3>Employment Category by PSIC Sector</h3>
        <p class="subtitle">Table 3 &mdash; Establishments classified by employment size (fewer than 10 vs 10 and above employees)</p>
        <div class="section">
          <div class="chart-wrap" style="height:420px"><canvas id="chart-emp-cat"></canvas></div>
        </div>
      </div>
      <div class="tab-content" id="tab3" style="padding:24px">
        <h3>Unit Type by Employment Category</h3>
        <p class="subtitle">Table 4 &mdash; Establishments classified by unit type and employment size</p>
        <div class="section">
          <div class="chart-wrap" style="height:420px"><canvas id="chart-ut-emp"></canvas></div>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
const RAW = %s;

const COLORS = [
  "#1a6eb5","#0e9e6b","#e07b00","#b81a1a","#6b3fa0",
  "#0e7eb5","#9e1a6b","#3fa06b","#e0a500","#1a3a5c",
  "#5dade2","#52be80","#f39c12","#e74c3c","#9b59b6",
  "#1abc9c","#e67e22","#3498db","#2ecc71","#e91e63"
];

let charts = {};

function fmt(n){ if(!n && n!==0) return "N/A"; return n.toLocaleString(); }
function fmtShort(n){ if(!n && n!==0) return "0"; if(n>=1e6) return (n/1e6).toFixed(1)+"M"; if(n>=1e3) return (n/1e3).toFixed(1)+"K"; return n; }

// Populate division dropdown
const divSel = document.getElementById("sel-division");
Object.keys(RAW.divisions).forEach(div => {
  const o = document.createElement("option");
  o.value = div; o.textContent = div;
  divSel.appendChild(o);
});

function onDivisionChange() {
  const div = divSel.value;
  const distSel = document.getElementById("sel-district");
  distSel.innerHTML = "<option value=\\"\\">Select District</option>";
  if (div && RAW.divisions[div]) {
    RAW.divisions[div].forEach(d => {
      const o = document.createElement("option");
      o.value = d; o.textContent = toTitle(d);
      distSel.appendChild(o);
    });
  } else {
    // All districts
    const allDistricts = getAllDistricts();
    allDistricts.forEach(d => {
      const o = document.createElement("option");
      o.value = d; o.textContent = toTitle(d);
      distSel.appendChild(o);
    });
  }
  document.getElementById("sel-tehsil").innerHTML = "<option value=\\"\\">All Tehsils</option>";
  renderAll();
}

function onDistrictChange() {
  const dist = document.getElementById("sel-district").value;
  const tehSel = document.getElementById("sel-tehsil");
  tehSel.innerHTML = "<option value=\\"\\">All Tehsils</option>";
  if (dist && RAW.tehsils[dist]) {
    RAW.tehsils[dist].forEach(t => {
      const o = document.createElement("option");
      o.value = t; o.textContent = t;
      tehSel.appendChild(o);
    });
  }
  renderAll();
}

function getAllDistricts() {
  return Object.keys(RAW.psic).sort();
}

function toTitle(s) {
  return s.split(" ").map(w => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase()).join(" ");
}

function getSelectedDistrict() {
  return document.getElementById("sel-district").value;
}

function resetFilters() {
  divSel.value = "";
  onDivisionChange();
}

function switchTab(i) {
  document.querySelectorAll(".tab").forEach((t,j) => t.classList.toggle("active", i===j));
  document.querySelectorAll(".tab-content").forEach((t,j) => t.classList.toggle("active", i===j));
}

function destroyChart(id) {
  if (charts[id]) { charts[id].destroy(); delete charts[id]; }
}

function makeBar(id, labels, datasets, opts={}) {
  destroyChart(id);
  const ctx = document.getElementById(id);
  if (!ctx) return;
  charts[id] = new Chart(ctx, {
    type: "bar",
    data: { labels, datasets },
    options: {
      responsive: true, maintainAspectRatio: false,
      plugins: {
        legend: { position: "top", labels: { boxWidth: 12, font: { size: 11 } } },
        tooltip: {
          callbacks: {
            label: ctx => " " + ctx.dataset.label + ": " + fmt(ctx.parsed.y)
          }
        }
      },
      scales: {
        x: {
          ticks: { font: { size: 10 }, maxRotation: 40, minRotation: 20 },
          grid: { display: false }
        },
        y: {
          ticks: { font: { size: 10 }, callback: v => fmtShort(v) },
          grid: { color: "#f0f0f0" },
          beginAtZero: true
        }
      },
      ...opts
    }
  });
}

function makeGroupedBar(id, labels, ds1, ds2, label1, label2) {
  destroyChart(id);
  const ctx = document.getElementById(id);
  if (!ctx) return;
  charts[id] = new Chart(ctx, {
    type: "bar",
    data: {
      labels,
      datasets: [
        { label: label1, data: ds1, backgroundColor: "#1a6eb5", borderRadius: 4 },
        { label: label2, data: ds2, backgroundColor: "#0e9e6b", borderRadius: 4 }
      ]
    },
    options: {
      responsive: true, maintainAspectRatio: false,
      plugins: {
        legend: { position: "top", labels: { boxWidth: 12, font: { size: 11 } } },
        tooltip: { callbacks: { label: ctx => " " + ctx.dataset.label + ": " + fmt(ctx.parsed.y) } }
      },
      scales: {
        x: { ticks: { font: { size: 10 }, maxRotation: 45 }, grid: { display: false } },
        y: { ticks: { font: { size: 10 }, callback: v => fmtShort(v) }, beginAtZero: true, grid: { color: "#f0f0f0" } }
      }
    }
  });
}

function getDistrictData(table) {
  const dist = getSelectedDistrict();
  if (!dist) return null;
  const tbl = RAW[table];
  return tbl[dist] || null;
}

function getPSICRows(dist) {
  const rows = dist ? (RAW.psic[dist] || []) : [];
  return Array.isArray(rows) ? rows : Object.values(rows).filter(r => r.description !== "Total");
}
function getEmpRows(dist) {
  const rows = dist ? (RAW.employment[dist] || []) : [];
  return Array.isArray(rows) ? rows : Object.values(rows).filter(r => r.description !== "Total");
}
function getUTRows(dist) {
  const rows = dist ? (RAW.unit_type[dist] || []) : [];
  return Array.isArray(rows) ? rows : Object.values(rows).filter(r => r.description !== "Total");
}
function getUTEmpRows(dist) {
  const rows = dist ? (RAW.unit_employment[dist] || []) : [];
  return Array.isArray(rows) ? rows : Object.values(rows).filter(r => r.description !== "Total");
}

function shortLabel(s) {
  const map = {
    "Agriculture, forestry and fishing": "Agriculture",
    "Mining and quarrying": "Mining",
    "Manufacturing": "Manufacturing",
    "Electricity, gas, steam and air conditioning supply": "Electricity/Gas",
    "Water supply; sewerage, waste management and remediation activities": "Water/Waste",
    "Construction": "Construction",
    "Wholesale and retail trade; repair of motor vehicles and motorcycles": "Wholesale/Retail",
    "Transportation and storage": "Transport",
    "Accommodation and food service activities": "Food Service",
    "Information and communication": "ICT",
    "Financial and insurance activities": "Finance",
    "Real estate activities": "Real Estate",
    "Professional, scientific and technical activities": "Professional",
    "Administrative and support service activities": "Admin Support",
    "Public administration and defence; compulsory social security": "Public Admin",
    "Education": "Education",
    "Human health and social work activities": "Health",
    "Arts, entertainment and recreation": "Arts/Recreation",
    "Other service activities": "Other Services",
    "Activities of extraterritorial organizations and bodies": "Extraterritorial",
    "Others": "Others"
  };
  return map[s] || (s.length > 22 ? s.substring(0,20)+"..." : s);
}

function renderSummary(dist) {
  const psicRows = getPSICRows(dist);
  const empRows  = getEmpRows(dist);
  const utRows   = getUTRows(dist);

  let totalEstab=0, totalWF=0, totalLT10=0, totalGT10=0;
  psicRows.forEach(r => { if(r.establishments) totalEstab+=r.establishments; if(r.workforce) totalWF+=r.workforce; });
  empRows.forEach(r => { if(r.less_than_10) totalLT10+=r.less_than_10; if(r.ten_and_above) totalGT10+=r.ten_and_above; });

  const cards = [
    { icon:"&#127981;", label:"Total Establishments", value:fmt(totalEstab), sub:"All sectors combined", cls:"" },
    { icon:"&#128101;", label:"Total Workforce", value:fmt(totalWF), sub:"Persons employed", cls:"green" },
    { icon:"&#128202;", label:"Small Estabs (< 10)", value:fmt(totalLT10), sub:"Fewer than 10 employees", cls:"" },
    { icon:"&#127970;", label:"Large Estabs (10+)", value:fmt(totalGT10), sub:"10 or more employees", cls:"amber" },
    { icon:"&#128209;", label:"Unit Types", value:utRows.length, sub:"Distinct categories", cls:"" },
    { icon:"&#127758;", label:"PSIC Sectors", value:psicRows.filter(r=>r.establishments>0).length, sub:"Active sectors", cls:"red" }
  ];

  const html = cards.map(c => `
    <div class="card ${c.cls}">
      <div class="card-icon">${c.icon}</div>
      <div class="card-label">${c.label}</div>
      <div class="card-value">${c.value}</div>
      <div class="card-sub">${c.sub}</div>
    </div>`).join("");
  document.getElementById("summary-cards").innerHTML =
    (dist ? `<div class="district-tag">&#128205; ${toTitle(dist)}</div>` : "") +
    `<div class="summary-cards">${html}</div>`;
}

function renderPSICCharts(dist) {
  const rows = getPSICRows(dist).filter(r => r.establishments > 0 || r.workforce > 0);
  const labels = rows.map(r => shortLabel(r.description));
  const estabs = rows.map(r => r.establishments || 0);
  const wf     = rows.map(r => r.workforce || 0);
  const bgColors = rows.map((_,i) => COLORS[i %% COLORS.length]);

  makeBar("chart-psic-estab", labels,
    [{ label:"Establishments", data:estabs, backgroundColor:bgColors, borderRadius:4 }]);
  makeBar("chart-psic-workforce", labels,
    [{ label:"Workforce", data:wf, backgroundColor:bgColors.map(c=>c+"bb"), borderRadius:4 }]);
}

function renderUTCharts(dist) {
  const rows = getUTRows(dist).filter(r => r.establishments > 0);
  const labels = rows.map(r => r.description);
  const estabs = rows.map(r => r.establishments || 0);
  const wf     = rows.map(r => r.workforce || 0);
  const bgColors = rows.map((_,i) => COLORS[i %% COLORS.length]);

  makeBar("chart-ut-estab", labels,
    [{ label:"Establishments", data:estabs, backgroundColor:bgColors, borderRadius:4 }]);
  makeBar("chart-ut-workforce", labels,
    [{ label:"Workforce", data:wf, backgroundColor:bgColors.map(c=>c+"bb"), borderRadius:4 }]);
}

function renderEmpCatCharts(dist) {
  const rows = getEmpRows(dist).filter(r => (r.less_than_10||0)+(r.ten_and_above||0) > 0);
  const labels = rows.map(r => shortLabel(r.description));
  const lt10   = rows.map(r => r.less_than_10 || 0);
  const gt10   = rows.map(r => r.ten_and_above || 0);
  makeGroupedBar("chart-emp-cat", labels, lt10, gt10, "< 10 Employees", "10+ Employees");
}

function renderUTEmpCharts(dist) {
  const rows = getUTEmpRows(dist).filter(r => (r.less_than_10||0)+(r.ten_and_above||0) > 0);
  const labels = rows.map(r => r.description);
  const lt10   = rows.map(r => r.less_than_10 || 0);
  const gt10   = rows.map(r => r.ten_and_above || 0);
  makeGroupedBar("chart-ut-emp", labels, lt10, gt10, "< 10 Employees", "10+ Employees");
}

function renderAll() {
  const dist = getSelectedDistrict() || null;
  renderSummary(dist);
  if (dist) {
    renderPSICCharts(dist);
    renderUTCharts(dist);
    renderEmpCatCharts(dist);
    renderUTEmpCharts(dist);
  } else {
    destroyChart("chart-psic-estab"); destroyChart("chart-psic-workforce");
    destroyChart("chart-ut-estab"); destroyChart("chart-ut-workforce");
    destroyChart("chart-emp-cat"); destroyChart("chart-ut-emp");
    ["chart-psic-estab","chart-psic-workforce","chart-ut-estab","chart-ut-workforce","chart-emp-cat","chart-ut-emp"].forEach(id => {
      const c = document.getElementById(id);
      if(c) { const p = c.parentElement; p.innerHTML = "<div class=\'no-data\'>&#128270; Select a district to view charts</div>"; }
    });
  }
}

// Init
onDivisionChange();
renderAll();
</script>
</body>
</html>', json_str)

writeLines(html, 'EC_Census_Dashboard.html', useBytes=TRUE)
cat('Dashboard written to EC_Census_Dashboard.html\n')
