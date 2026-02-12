<?php
if (isset($_GET['action'])) {
    if ($_GET['action'] == "start_mysql") shell_exec("mysqld > /dev/null 2>&1 &");
    if ($_GET['action'] == "stop_mysql") shell_exec("pkill mysqld");
    header("Location: /");
    exit;
}

$ramTotal = intval(filter_var(shell_exec("grep MemTotal /proc/meminfo"), FILTER_SANITIZE_NUMBER_INT)) / 1024;
$ramFree  = intval(filter_var(shell_exec("grep MemAvailable /proc/meminfo"), FILTER_SANITIZE_NUMBER_INT)) / 1024;
$ramUsed  = $ramTotal - $ramFree;
$ramPercent = round(($ramUsed / $ramTotal) * 100);

$cpuUsage = 0;
$cpuStat = @shell_exec("cat /proc/stat 2>/dev/null");
if ($cpuStat) {
    $lines = explode("\n", $cpuStat);
    if (!empty($lines[0])) {
        $cpuData = preg_split('/\s+/', trim($lines[0]));
        if (count($cpuData) >= 5) {
            $totalCpu = array_sum(array_slice($cpuData,1));
            $idleCpu = $cpuData[4];
            if ($totalCpu > 0) $cpuUsage = round((1 - ($idleCpu / $totalCpu)) * 100);
        }
    }
}

$diskTotal = disk_total_space("/");
$diskFree  = disk_free_space("/");
$diskUsed  = $diskTotal - $diskFree;
$diskPercent = round(($diskUsed / $diskTotal) * 100);

$apacheRunning = !empty(shell_exec("ps aux | grep httpd | grep -v grep"));
$mysqlRunning  = !empty(shell_exec("ps aux | grep mysqld | grep -v grep"));
?>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>MAI Cyber Neon Panel</title>

<style>
body{
 margin:0;
 font-family:Consolas,monospace;
 background:#070b14;
 color:#e2e8f0; /* soft light text */
}

/* NAVBAR */
.navbar{
 display:flex;
 justify-content:space-between;
 align-items:center;
 padding:15px 25px;
 background:#0f172a;
 border-bottom:1px solid #00eaff33;
 box-shadow:0 0 20px #00eaff22;
}

.logo{
 font-size:18px;
 font-weight:bold;
 color:#00eaff; /* cyan accent */
 text-shadow:0 0 8px #00eaff;
}

.toggle{
 cursor:pointer;
 padding:6px 12px;
 border:1px solid #00eaff;
 border-radius:6px;
 color:#00eaff;
}

/* LAYOUT */
.layout{
 display:flex;
 min-height:calc(100vh - 60px);
}

/* SIDEBAR */
.sidebar{
 width:220px;
 background:#0f172a;
 padding:20px;
 border-right:1px solid #00eaff22;
}

.sidebar a{
 display:block;
 padding:10px;
 margin-bottom:10px;
 text-decoration:none;
 color:#cbd5e1;
 border:1px solid #00eaff22;
 border-radius:6px;
 transition:.3s;
}

.sidebar a:hover{
 background:#00eaff;
 color:#070b14;
 box-shadow:0 0 15px #00eaff;
}

/* MAIN GRID */
.main{
 flex:1;
 padding:30px;
 display:grid;
 grid-template-columns:repeat(auto-fit,minmax(320px,1fr));
 gap:25px;
}

/* CARD */
.card{
 background:#0f172a;
 padding:25px;
 border-radius:14px;
 border:1px solid #00eaff22;
 box-shadow:0 0 20px #00eaff11;
 transition:.3s;
}

.card:hover{
 transform:translateY(-5px);
 box-shadow:0 0 25px #8b5cf6aa; /* purple glow hover */
}

.card h3{
 margin-top:0;
 color:#8b5cf6; /* purple header */
}

/* PROGRESS BAR */
.progress{
 height:16px;
 background:#1e293b;
 border-radius:10px;
 overflow:hidden;
 margin-top:10px;
}

.progress-bar{
 height:100%;
 box-shadow:0 0 12px currentColor;
}

/* Different colors per monitoring */
.cpu{
 background:linear-gradient(90deg,#ef4444,#f97316);
 color:#ef4444;
}

.ram{
 background:linear-gradient(90deg,#3b82f6,#06b6d4);
 color:#3b82f6;
}

.disk{
 background:linear-gradient(90deg,#8b5cf6,#a855f7);
 color:#8b5cf6;
}

/* STATUS */
.status-green{
 color:#22c55e;
 font-weight:bold;
}

.status-red{
 color:#ef4444;
 font-weight:bold;
}

/* BUTTONS */
button{
 padding:6px 10px;
 margin-top:8px;
 border:none;
 border-radius:6px;
 cursor:pointer;
 font-weight:bold;
}

button{
 background:#00eaff;
 color:#070b14;
}

button.stop{
 background:#ef4444;
 color:white;
}
.light{
 background:#f8fafc !important;
 color:#111827 !important;
}

.light .navbar,
.light .sidebar,
.light .card{
 background:#ffffff !important;
 color:#111827 !important;
}

.light .logo{
 color:#2563eb !important;
}

/* MOBILE */
@media(max-width:768px){
 .layout{flex-direction:column;}
 .sidebar{
  width:100%;
  display:flex;
  justify-content:space-around;
 }
}
</style>
</head>

<body>

<div class="navbar">
 <div class="logo">⚡ MAI CYBER NEON ⚡</div>
 <div class="toggle" onclick="toggleTheme()" id="themeBtn">🌙</div>
</div>

<div class="layout">

<div class="main">

<div class="card">
<h3>🖥 Service Status</h3>
<p>Apache: <?php echo $apacheRunning ? "<span class='status-green'>● ONLINE</span>" : "<span class='status-red'>● OFFLINE</span>"; ?></p>
<p>MySQL: <?php echo $mysqlRunning ? "<span class='status-green'>● ONLINE</span>" : "<span class='status-red'>● OFFLINE</span>"; ?></p>
<button onclick="location.href='?action=start_mysql'">Start MySQL</button>
<button class="stop" onclick="location.href='?action=stop_mysql'">Stop MySQL</button>
  <button onclick="location.href='/phpmyadmin'">phpMyAdmin</button>
  <button onclick="location.href='/phpinfo.php'">PHP Info</button>
</div>


<div class="card">
<h3>🔥 CPU Usage</h3>
<p><?php echo $cpuUsage; ?>%</p>
<div class="progress">
 <div class="progress-bar cpu" style="width:<?php echo $cpuUsage; ?>%"></div>
</div>
</div>

<div class="card">
<h3>💾 RAM Usage</h3>
<p><?php echo round($ramUsed,1); ?> MB / <?php echo round($ramTotal,1); ?> MB (<?php echo $ramPercent; ?>%)</p>
<div class="progress">
 <div class="progress-bar ram" style="width:<?php echo $ramPercent; ?>%"></div>
</div>
</div>

<div class="card">
<h3>📂 Disk Usage</h3>
<p><?php echo round($diskUsed/1024/1024/1024,2); ?> GB / <?php echo round($diskTotal/1024/1024/1024,2); ?> GB (<?php echo $diskPercent; ?>%)</p>
<div class="progress">
 <div class="progress-bar disk" style="width:<?php echo $diskPercent; ?>%"></div>
</div>
</div>

</div>
</div>

<script>
function toggleTheme(){
    document.body.classList.toggle("light");

    const btn = document.getElementById("themeBtn");

    if(document.body.classList.contains("light")){
        btn.innerHTML = "☀";
    } else {
        btn.innerHTML = "🌙";
    }
}
</script>


</body>
</html>