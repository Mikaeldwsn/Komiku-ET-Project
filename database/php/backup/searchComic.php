<?php
extract($_POST);

header("Access-Control-Allow-Origin: *");
$arr = null;

$conn = new mysqli("localhost", "flutter_160423007", "ubaya", "flutter_160423007");

if ($conn->connect_error) {
    $arr = ["result" => "error", "message" => "unable to connect"];
} else {

    $search = "$keyword%";

    try{
        if($category_id != null){
            $sql = "
                SELECT DISTINCT c.*, u.id as creator_id, u.username, u.email FROM comics c 
                INNER JOIN  comic_category cc ON c.id = cc.comic_id INNER JOIN users u ON c.user_id = u.id
                WHERE cc.category_id = ? AND c.title LIKE ?
            ";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("is", $category_id, $search);

        } else{
            $sql = "
                SELECT DISTINCT c.*, u.id as creator_id, u.username, u.email FROM comics c 
                INNER JOIN  comic_category cc ON c.id = cc.comic_id INNER JOIN users u ON c.user_id = u.id
                WHERE c.title LIKE ?
            ";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("s", $search);
        }

        $stmt->execute();
        $result = $stmt->get_result();

        $data = [];
        if ($result->num_rows > 0) {
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
                    "creator" => $creator
                ];

                $data[] = $comic;
            }
            $arr = ["result" => "success", "data" => $data];
        } else{
            $arr = ["result" => "success", "data" => null];
        }

        $stmt->close();
        $conn->close();
    } 
    catch(Exception $e){
        $arr = ["result" => "error", "message" => $e->getMessage()];
    }
}

echo json_encode($arr);