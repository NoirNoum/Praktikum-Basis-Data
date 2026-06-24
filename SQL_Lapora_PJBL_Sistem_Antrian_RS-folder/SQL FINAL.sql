-- ============================================================================
-- SCRIPT SQL LENGKAP - SISTEM ANTREAN PASIEN RUMAH SAKIT
-- Kelompok: 
Pardede Putra Anjasmara (2505060061)
Muhammad Zhio Affarel (2505060063)
Aghnia Azka Dhiya’ (2505060065)
Aufa Abid Rahman Nashir (2505060055)
Salwa JJ Saputri (2505060051)
-- Program Studi: Teknologi Informasi - Universitas Tidar
-- ============================================================================

CREATE DATABASE rumah_sakit;
USE rumah_sakit;

-- ============================================================================
-- 1. PEMBUATAN TABEL (DDL)
-- ============================================================================

-- Tabel Pasien
CREATE TABLE pasien(
    id_pasien INT PRIMARY KEY AUTO_INCREMENT,
    nama_pasien VARCHAR(100) NOT NULL,
    nik VARCHAR(20) UNIQUE,
    no_telp VARCHAR(15),
    jenis_kelamin ENUM('Laki-laki', 'Perempuan')
);

-- Tabel Dokter
CREATE TABLE dokter(
    id_dokter INT PRIMARY KEY AUTO_INCREMENT,
    nama_dokter VARCHAR(100) NOT NULL,
    spesialisasi VARCHAR(100)
);

-- Tabel Poli
CREATE TABLE poli(
    id_poli INT PRIMARY KEY AUTO_INCREMENT,
    nama_poli VARCHAR(100) NOT NULL
);

-- Tabel Jadwal
CREATE TABLE jadwal(
    id_jadwal INT PRIMARY KEY AUTO_INCREMENT,
    hari VARCHAR(20),
    jam_mulai TIME,
    jam_selesai TIME,
    id_dokter INT,
    id_poli INT,
    FOREIGN KEY (id_dokter) REFERENCES dokter(id_dokter),
    FOREIGN KEY (id_poli) REFERENCES poli(id_poli)
);

-- Tabel Antrean
CREATE TABLE antrean(
    id_antrean INT PRIMARY KEY AUTO_INCREMENT,
    no_antrean INT NOT NULL,
    tgl_antrean DATE,
    keluhan TEXT,
    status_antrean ENUM('Menunggu', 'Dipanggil', 'Selesai', 'Batal'),
    id_pasien INT,
    id_jadwal INT,
    FOREIGN KEY (id_pasien) REFERENCES pasien(id_pasien),
    FOREIGN KEY (id_jadwal) REFERENCES jadwal(id_jadwal)
);

-- Tabel Kunjungan
CREATE TABLE kunjungan(
    id_kunjungan INT PRIMARY KEY AUTO_INCREMENT,
    id_antrean INT,
    diagnosa TEXT,
    tindakan TEXT,
    resep_obat TEXT,
    FOREIGN KEY (id_antrean) REFERENCES antrean(id_antrean)
);

-- Tabel untuk Log Trigger (Sesuai dengan screenshot di Laporan Halaman 23 & 30)
CREATE TABLE log_status_antrean(
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    id_pendaftaran VARCHAR(10), -- Sesuai dengan tipe data di trigger laporan
    status_lama VARCHAR(20),
    status_baru VARCHAR(20),
    waktu_perubahan DATETIME
);


-- ============================================================================
-- 2. PENGISIAN DATA (DML)
-- ============================================================================

-- Insert Tabel Pasien
INSERT INTO pasien (nama_pasien, nik, no_telp, jenis_kelamin) VALUES
('Budi Santoso', '1234567890123456', '081234567890', 'Laki-laki'),
('Fahmi Seyhat', '1234567890123478', '081234567833', 'Laki-laki'),
('Ahmad Fauzi', '1234567890123499', '081234567899', 'Laki-laki'),
('Sri Sudarti', '1234567890123765', '081234567891', 'Perempuan');

-- Insert Tabel Dokter
INSERT INTO dokter (nama_dokter, spesialisasi) VALUES
('Dr. Saiful', 'Umum'),
('Dr. Gia', 'Gigi'),
('Dr. Erni', 'Mata'),
('Dr. Tirta', 'Ortopedi');

-- Insert Tabel Poli
INSERT INTO poli (nama_poli) VALUES
('Poli Umum'),
('Poli Gigi'),
('Poli Mata'),
('Poli Ortopedi');

-- Insert Tabel Jadwal
INSERT INTO jadwal (hari, jam_mulai, jam_selesai, id_dokter, id_poli) VALUES
('Senin', '08:00:00', '12:00:00', 2, 2),
('Senin', '10:00:00', '14:00:00', 1, 1),
('Rabu', '08:00:00', '11:00:00', 3, 3),
('Kamis', '12:00:00', '15:30:00', 4, 4);

-- Insert Tabel Antrean
INSERT INTO antrean (no_antrean, keluhan, status_antrean, id_pasien, id_jadwal, tgl_antrean) VALUES
(1, 'Flu, Batuk', 'Dipanggil', 1, 2, '2026-06-14'),
(2, 'Sakit gigi', 'Dipanggil', 2, 1, '2026-06-14'),
(3, 'Demam tinggi', 'Menunggu', 4, 1, '2026-06-14'),
(1, 'Mata merah, perih', 'Dipanggil', 3, 3, '2026-06-15'),
(1, 'Nyeri punggung', 'Dipanggil', 2, 4, '2026-06-17');

-- Insert Tabel Kunjungan
INSERT INTO kunjungan (id_antrean, diagnosa, tindakan, resep_obat) VALUES
(1, 'Flu', 'Pemeriksaan Umum', 'Paracetamol'),
(2, 'Gigi Berlubang', 'Tambal gigi', 'Ibuprofen'),
(3, 'Demam', 'Pemeriksaan Umum', 'Paracetamol'),
(4, 'Iritasi Mata', 'Pemeriksaan Mata', 'Insto'),
(5, 'Asam Urat', 'Pemeriksaan Ortopedi', 'Allopurinol');

-- Update & Delete Sesuai Laporan Halaman 18
UPDATE kunjungan SET diagnosa = 'Pilek' WHERE id_kunjungan = 1;
ALTER TABLE kunjungan DROP COLUMN tindakan;


-- ============================================================================
-- 3. IMPLEMENTASI FITUR LANJUTAN (VIEW, PROCEDURE, TRIGGER)
-- ============================================================================

-- VIEW: view_data_antrean (Sesuai Halaman 21)
CREATE VIEW view_data_antrean AS
SELECT 
    p.nama_pasien,
    d.nama_dokter,
    po.nama_poli,
    a.no_antrean,
    a.status_antrean
FROM antrean a
JOIN pasien p ON a.id_pasien = p.id_pasien
JOIN jadwal j ON a.id_jadwal = j.id_jadwal
JOIN dokter d ON j.id_dokter = d.id_dokter
JOIN poli po ON j.id_poli = po.id_poli;

-- STORED PROCEDURE: tambah_pasien (Sesuai Halaman 22)
DELIMITER //
CREATE PROCEDURE tambah_pasien(
    IN p_id_pasien CHAR(5), -- Catatan: di struktur tabel id_pasien itu INT AUTO_INCREMENT, tapi di laporan dibuat CHAR(5) untuk input. Script ini mengikuti persis input dari laporan.
    IN p_nama_pasien VARCHAR(100),
    IN p_alamat TEXT,
    IN p_kontak VARCHAR(15),
    IN p_tanggal_lahir DATE,
    IN p_jenis_kelamin ENUM('L','P')
)
BEGIN
    -- Menyesuaikan dengan input prosedur di laporan, mengabaikan struktur tabel awal
    INSERT INTO pasien (id_pasien, nama_pasien, alamat, no_telp, tgl_lahir, jenis_kelamin) -- Asumsi kolom tgl_lahir ditambahkan belakangan
    VALUES (
        p_id_pasien,
        p_nama_pasien,
        p_alamat,
        p_kontak,
        p_tanggal_lahir,
        p_jenis_kelamin
    );
END //
DELIMITER ;

-- TRIGGER: trg_log_status (Sesuai Halaman 23)
-- Catatan: Di laporan (hal 23 & 30), trigger ini menggunakan tabel 'pendaftaran', 
-- tapi di struktur tabel (hal 13) namanya 'antrean'. Script ini menggunakan nama 'antrean'
-- agar relasinya berjalan, namun logic-nya sama persis dengan laporan.
DELIMITER //
CREATE TRIGGER trg_log_status
AFTER UPDATE ON antrean
FOR EACH ROW
BEGIN
    IF OLD.status_antrean <> NEW.status_antrean THEN
        INSERT INTO log_status_antrean(
            id_pendaftaran,
            status_lama,
            status_baru,
            waktu_perubahan
        )
        VALUES(
            OLD.id_antrean,
            OLD.status_antrean,
            NEW.status_antrean,
            NOW()
        );
    END IF;
END //
DELIMITER ;


-- ============================================================================
-- 4. PENGUJIAN QUERY (BAB IV)
-- ============================================================================

-- INNER JOIN
SELECT 
    p.nama_pasien,
    d.nama_dokter,
    pd.no_antrean AS nomor_antrean,
    pd.status_antrean
FROM antrean pd
INNER JOIN pasien p ON pd.id_pasien = p.id_pasien
INNER JOIN jadwal j ON pd.id_jadwal = j.id_jadwal
INNER JOIN dokter d ON j.id_dokter = d.id_dokter;

-- LEFT JOIN
SELECT 
    p.nama_pasien,
    pd.no_antrean AS nomor_antrean
FROM pasien p
LEFT JOIN antrean pd ON p.id_pasien = pd.id_pasien;

-- JOIN Multi-Tabel
SELECT 
    p.nama_pasien,
    d.nama_dokter,
    pl.nama_poli,
    pd.no_antrean AS nomor_antrean,
    pd.status_antrean
FROM antrean pd
JOIN pasien p ON pd.id_pasien = p.id_pasien
JOIN jadwal j ON pd.id_jadwal = j.id_jadwal
JOIN dokter d ON j.id_dokter = d.id_dokter
JOIN poli pl ON j.id_poli = pl.id_poli;

-- Subquery 1
SELECT nama_pasien
FROM pasien
WHERE id_pasien IN (
    SELECT id_pasien
    FROM antrean
);

-- Subquery 2
SELECT nama_dokter
FROM dokter
WHERE id_dokter IN (
    SELECT id_dokter
    FROM jadwal
);

-- Pengujian Stored Procedure
-- CALL tambah_pasien('P005', 'Rudi Hartono', 'Semarang', '08123456789', '2002-05-10', 'L');

-- Pengujian Trigger
-- UPDATE antrean SET status_antrean='Selesai' WHERE id_antrean=1;
-- SELECT * FROM log_status_antrean;


-- ============================================================================
-- 5. IMPLEMENTASI INDEX & USER SECURITY
-- ============================================================================

-- Create Index (Sesuai Halaman 31)
CREATE INDEX idx_tanggal_daftar ON antrean(tgl_antrean);

-- User Creation & Privileges (Sesuai Halaman 24 & 25)
CREATE USER 'admin_rs'@'localhost' IDENTIFIED BY 'admin123';
CREATE USER 'operator_rs'@'localhost' IDENTIFIED BY 'operator123';

GRANT ALL PRIVILEGES ON rumah_sakit.* TO 'admin_rs'@'localhost';
GRANT SELECT, INSERT ON rumah_sakit.* TO 'operator_rs'@'localhost';
REVOKE INSERT ON rumah_sakit.* FROM 'operator_rs'@'localhost';
