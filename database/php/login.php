<?php
header("Access-Control-Allow-Origin: *");
$arr = null;

// Ganti dengan kredensial database Anda di ubaya.cloud
$conn = new mysqli("localhost", "flutter_160423007", "ubaya", "flutter_160423007");

if ($conn->connect_error) {
    $arr = ["result" => "error", "message" => "unable to connect"];
} else {
    // Ambil parameter yang dikirim dari Flutter (body POST)
    extract($_POST);
    // $username dan $password otomatis terbentuk dari extract()

    $sql = "SELECT * FROM users WHERE username = ? AND password = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $username, $password);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $r = mysqli_fetch_assoc($result);
        $arr = [
            "result"   => "success",
            "user_id"  => $r['id'],
            "username" => $r['username'],
            "email"    => $r['email']
        ];
    } else {
        $arr = ["result" => "error", "message" => "Username atau password salah"];
    }

    $stmt->close();
    $conn->close();
}

echo json_encode($arr);

// For hashing
//   saat register -> $hashed = password_hash($password, PASSWORD_DEFAULT);
//   saat login     -> ganti query jadi SELECT berdasarkan username saja,
//                      lalu cek: password_verify($password, $r['password'])
?>