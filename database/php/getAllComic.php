<?php
header("Access-Control-Allow-Origin: *");
$arr = null;

$conn = new mysqli("localhost", "flutter_160423007", "ubaya", "flutter_160423007");

if ($conn->connect_error) {
    $arr = ["result" => "error", "message" => "unable to connect"];
} else {
    $sql = "
        SELECT c.*, u.id as creator_id, u.username, u.email,
               (SELECT GROUP_CONCAT(cat.name) 
                FROM comic_category cc2 
                INNER JOIN categories cat ON cc2.category_id = cat.id 
                WHERE cc2.comic_id = c.id) AS categories
        FROM comics c 
        INNER JOIN comic_category cc ON c.id = cc.comic_id 
        INNER JOIN users u ON c.user_id = u.id
        GROUP BY c.id";
    $stmt = $conn->prepare($sql);

    $stmt->execute();
    $result = $stmt->get_result();

    $data = [];
    if ($result->num_rows > 0) {
        $data = [];
        while ($r = $result->fetch_assoc()) {
            $creator = [
                "id" => $r['creator_id'],
                "username" => $r['username'],
                "email" => $r['email']
            ];
            $comic = [
                "id" => $r['id'],
                "title" => $r['title'],
                "poster_url" => $r['poster_url'],
                "view_count" => $r['view_count'],
                "creator" => $creator,
                "categories" => $r['categories']
            ];

            $data[] = $comic;
        }
        $arr = ["result" => "success", "data" => $data];
    } else {
        $arr = ["result" => "error", "message" => "no categories found"];
    }

    $stmt->close();
    $conn->close();
}

echo json_encode($arr);