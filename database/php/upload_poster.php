<?php
// upload_poster.php
// Terima gambar poster dalam base64, simpan ke folder images/posters/[comic_id]/
// lalu update kolom poster_url di tabel comics.
// mirip uploadscene64.php di Week 12.

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");

extract($_POST);
// $comic_id, $image (base64 string)

function savePosterImage($base64Image, $comicId) {
    $response = ["result" => "error", "message" => ""];

    $imageData = base64_decode($base64Image);
    if ($imageData === false) {
        $response["message"] = "Failed to decode Base64 image.";
        return $response;
    }

    $directory = "images/posters/" . htmlspecialchars($comicId);
    if (!is_dir($directory)) {
        if (!mkdir($directory, 0777, true)) {
            $response["message"] = "Failed to create directory.";
            return $response;
        }
    }

    $timestamp = time();
    $filename = $timestamp . ".png";
    $filePath = $directory . "/" . $filename;

    if (file_put_contents($filePath, $imageData) === false) {
        $response["message"] = "Failed to save the file.";
        return $response;
    }

    $response["result"] = "success";
    $response["file_path"] = $filePath;
    return $response;
}

$saveResult = savePosterImage($image, $comic_id);

if ($saveResult["result"] == "success") {
    $conn = new mysqli("localhost", "flutter_[NRP]", "ubaya", "flutter_[NRP]");
    if (!$conn->connect_error) {
        $filePath = $saveResult["file_path"];
        $sql = "UPDATE comics SET poster_url = ? WHERE id = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("si", $filePath, $comic_id);
        $stmt->execute();
        $stmt->close();
        $conn->close();
    }
}

echo json_encode($saveResult);
?>