<?php

extract($_POST);

header("Access-Control-Allow-Origin: *");
$arr = null;

$conn = new mysqli("localhost", "flutter_160423007", "ubaya", "flutter_160423007");

if ($conn->connect_error) {
    $arr = ["result" => "error", "message" => "unable to connect"];
}
else {
        try{
                $sql = "SELECT 
                IFNULL(AVG(r.rating_value),0) AS rating,
                GROUP_CONCAT(DISTINCT cat.name) AS categories
                FROM comics c INNER JOIN users u ON c.user_id = u.id
                LEFT JOIN ratings r
                ON c.id = r.comic_id
                LEFT JOIN comic_category cc
                ON c.id = cc.comic_id
                LEFT JOIN categories cat
                ON cc.category_id = cat.id
                WHERE c.id = ?
                GROUP BY c.id;
                ";
                $stmt = $conn->prepare($sql);
                $stmt->bind_param("i", $comic_id);
                $stmt->execute();
                $result = $stmt->get_result();

                if ($row = $result->fetch_assoc()) {
                       
                        $data = [
                        "rating" => (float)$row["rating"],
                        "categories" => $row["categories"],
                        ];
                        
                        $arr = [
                        "result" => "success",
                        "data" => $data
                        ];
                } else {

                        $arr = [
                        "result" => "success",
                        "message" => null
                        ];
                }

                $stmt->close();
                $conn->close();
    
        }catch(Exception $e){
                $arr = ["result" => "error", "message" => $e->getMessage()];
         }
            
        echo json_encode($arr);


}


