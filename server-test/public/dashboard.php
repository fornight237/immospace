<?php
$config = require __DIR__ . '/../config/config.php';
$db = $config['db'];
$dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', $db['host'], $db['name']);
try {
    $pdo = new PDO($dsn, $db['user'], $db['pass'], [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    $stmt = $pdo->query('SELECT id, uuid, device_id, source, application, sender, title, body, received_at, created_at FROM messages ORDER BY received_at DESC');
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (Exception $e) {
    $rows = [];
}
?><!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Message Relay - Dashboard</title>
  <style>table{border-collapse:collapse;width:100%}td,th{border:1px solid #ddd;padding:8px}tr:nth-child(even){background:#f9f9f9}</style>
</head>
<body>
  <h1>Message Relay - Dashboard</h1>
  <table>
    <thead><tr><th>ID</th><th>UUID</th><th>Device</th><th>Source</th><th>Application</th><th>Sender</th><th>Body</th><th>Received At</th><th>Created</th></tr></thead>
    <tbody>
    <?php foreach($rows as $r): ?>
      <tr>
        <td><?php echo htmlspecialchars($r['id']); ?></td>
        <td><?php echo htmlspecialchars($r['uuid']); ?></td>
        <td><?php echo htmlspecialchars($r['device_id']); ?></td>
        <td><?php echo htmlspecialchars($r['source']); ?></td>
        <td><?php echo htmlspecialchars($r['application']); ?></td>
        <td><?php echo htmlspecialchars($r['sender']); ?></td>
        <td><?php echo htmlspecialchars($r['body']); ?></td>
        <td><?php echo htmlspecialchars($r['received_at']); ?></td>
        <td><?php echo htmlspecialchars($r['created_at']); ?></td>
      </tr>
    <?php endforeach; ?>
    </tbody>
  </table>
</body>
</html>
