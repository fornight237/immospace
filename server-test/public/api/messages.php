<?php
// POST /api/messages
header('Content-Type: application/json');
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

// Check content type
$contentType = isset($_SERVER['CONTENT_TYPE']) ? trim($_SERVER['CONTENT_TYPE']) : '';
if (stripos($contentType, 'application/json') === false) {
    http_response_code(400);
    echo json_encode(['error' => 'Content-Type must be application/json']);
    exit;
}

$config = require __DIR__ . '/../../config/config.php';
// Optional token check
$authToken = $config['auth_token'] ?? null;
if ($authToken !== null) {
    $headers = getallheaders();
    $provided = $headers['X-API-Token'] ?? ($headers['x-api-token'] ?? null);
    if ($provided === null || $provided !== $authToken) {
        http_response_code(401);
        echo json_encode(['error' => 'Unauthorized']);
        exit;
    }
}

$raw = file_get_contents('php://input');
$data = json_decode($raw, true);
if (!is_array($data)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid JSON']);
    exit;
}

// Minimal validation
if (empty($data['uuid'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing uuid']);
    exit;
}

try {
    $dbconf = $config['db'];
    $dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', $dbconf['host'], $dbconf['name']);
    $pdo = new PDO($dsn, $dbconf['user'], $dbconf['pass'], [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    // Check duplicate
    $stmt = $pdo->prepare('SELECT id FROM messages WHERE uuid = :uuid LIMIT 1');
    $stmt->execute([':uuid' => $data['uuid']]);
    if ($stmt->fetch()) {
        http_response_code(409);
        echo json_encode(['error' => 'duplicate']);
        exit;
    }

    $insert = $pdo->prepare('INSERT INTO messages (uuid, device_id, source, application, sender, title, body, received_at) VALUES (:uuid, :device_id, :source, :application, :sender, :title, :body, FROM_UNIXTIME(:received_at))');
    $insert->execute([
        ':uuid' => $data['uuid'],
        ':device_id' => $data['device_id'] ?? null,
        ':source' => $data['source'] ?? null,
        ':application' => $data['application'] ?? null,
        ':sender' => $data['sender'] ?? null,
        ':title' => $data['title'] ?? null,
        ':body' => $data['body'] ?? null,
        ':received_at' => isset($data['received_at']) ? intval($data['received_at']) : time()
    ]);

    http_response_code(201);
    echo json_encode(['status' => 'created', 'id' => $pdo->lastInsertId()]);
    exit;
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'server_error', 'message' => $e->getMessage()]);
    exit;
}
