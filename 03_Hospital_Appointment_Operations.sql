/*
PROJECT 3: HOSPITAL APPOINTMENT OPERATIONS
Platform: Microsoft SQL Server / SSMS
Synthetic training data only. No real patient information.
Re-running rebuilds tables and sample data.
*/
IF DB_ID(N'HospitalOperationsDB') IS NULL CREATE DATABASE HospitalOperationsDB;
GO
USE HospitalOperationsDB;
GO
DROP VIEW IF EXISTS dbo.vw_AppointmentSummary;
DROP PROCEDURE IF EXISTS dbo.usp_DoctorSchedule;
DROP TABLE IF EXISTS dbo.Appointments;
DROP TABLE IF EXISTS dbo.Doctors;
DROP TABLE IF EXISTS dbo.Patients;
DROP TABLE IF EXISTS dbo.Departments;
GO
CREATE TABLE dbo.Departments(
 DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
 DepartmentName NVARCHAR(80) NOT NULL UNIQUE
);
CREATE TABLE dbo.Doctors(
 DoctorID INT IDENTITY(1,1) PRIMARY KEY,
 DoctorName NVARCHAR(120) NOT NULL,
 DepartmentID INT NOT NULL REFERENCES dbo.Departments(DepartmentID),
 ConsultationFee DECIMAL(10,2) NOT NULL CHECK(ConsultationFee>=0),
 IsActive BIT NOT NULL DEFAULT 1
);
CREATE TABLE dbo.Patients(
 PatientID INT IDENTITY(1,1) PRIMARY KEY,
 PatientName NVARCHAR(120) NOT NULL,
 BirthDate DATE NOT NULL,
 Gender VARCHAR(20) NOT NULL CHECK(Gender IN ('Female','Male','Non-binary','Prefer not to say')),
 City NVARCHAR(80) NOT NULL,
 RegistrationDate DATE NOT NULL
);
CREATE TABLE dbo.Appointments(
 AppointmentID INT IDENTITY(1,1) PRIMARY KEY,
 PatientID INT NOT NULL REFERENCES dbo.Patients(PatientID),
 DoctorID INT NOT NULL REFERENCES dbo.Doctors(DoctorID),
 AppointmentDateTime DATETIME2(0) NOT NULL,
 AppointmentStatus VARCHAR(20) NOT NULL CHECK(AppointmentStatus IN ('Scheduled','Completed','Cancelled','No-show')),
 Reason NVARCHAR(200) NOT NULL,
 FeeCharged DECIMAL(10,2) NOT NULL CHECK(FeeCharged>=0)
);
CREATE INDEX IX_Appointments_Date_Status ON dbo.Appointments(AppointmentDateTime,AppointmentStatus);
CREATE INDEX IX_Appointments_Doctor_Date ON dbo.Appointments(DoctorID,AppointmentDateTime);
GO
INSERT dbo.Departments(DepartmentName) VALUES
(N'Cardiology'),(N'Dermatology'),(N'General Medicine'),(N'Orthopedics'),(N'Pediatrics');
INSERT dbo.Doctors(DoctorName,DepartmentID,ConsultationFee) VALUES
(N'Dr. Asha Menon',1,900),(N'Dr. Vivek Rao',2,700),(N'Dr. Sana Qureshi',3,500),
(N'Dr. Kunal Shah',4,800),(N'Dr. Meera Nair',5,600),(N'Dr. Rahul Das',3,450);
INSERT dbo.Patients(PatientName,BirthDate,Gender,City,RegistrationDate) VALUES
(N'Patient Alpha','1988-03-12','Female',N'Mumbai','2024-11-01'),
(N'Patient Bravo','1975-08-24','Male',N'Pune','2024-11-03'),
(N'Patient Charlie','2001-01-05','Prefer not to say',N'Mumbai','2024-11-12'),
(N'Patient Delta','2012-06-17','Female',N'Nashik','2024-12-02'),
(N'Patient Echo','1994-10-30','Male',N'Pune','2024-12-12'),
(N'Patient Foxtrot','1968-04-08','Female',N'Mumbai','2025-01-02'),
(N'Patient Golf','1981-12-19','Male',N'Thane','2025-01-15'),
(N'Patient Hotel','2018-07-22','Female',N'Pune','2025-02-01'),
(N'Patient India','1999-02-14','Non-binary',N'Mumbai','2025-02-11'),
(N'Patient Juliet','1959-09-09','Male',N'Nashik','2025-02-19');
INSERT dbo.Appointments(PatientID,DoctorID,AppointmentDateTime,AppointmentStatus,Reason,FeeCharged) VALUES
(1,1,'2025-01-05T09:00:00','Completed',N'Routine check-up',900),
(2,3,'2025-01-05T10:00:00','Completed',N'General consultation',500),
(3,2,'2025-01-06T11:30:00','Cancelled',N'Skin concern',0),
(4,5,'2025-01-07T09:30:00','Completed',N'Child wellness',600),
(5,4,'2025-01-08T14:00:00','No-show',N'Knee pain',0),
(6,1,'2025-01-10T10:30:00','Completed',N'Follow-up',900),
(7,6,'2025-01-12T12:00:00','Completed',N'Fever',450),
(8,5,'2025-01-15T09:00:00','Scheduled',N'Vaccination consultation',600),
(9,2,'2025-02-02T13:00:00','Completed',N'Skin rash',700),
(10,4,'2025-02-04T15:00:00','Completed',N'Joint pain',800),
(1,3,'2025-02-11T10:00:00','Completed',N'General consultation',500),
(2,1,'2025-02-13T11:00:00','Cancelled',N'Follow-up',0),
(3,6,'2025-03-01T09:00:00','Completed',N'Annual check-up',450),
(4,5,'2025-03-04T10:30:00','No-show',N'Child wellness',0),
(5,4,'2025-03-11T14:30:00','Completed',N'Back pain',800),
(6,1,'2025-03-15T09:30:00','Scheduled',N'Cardiac review',900),
(7,3,'2025-04-02T11:00:00','Completed',N'General consultation',500),
(8,5,'2025-04-06T10:00:00','Completed',N'Child wellness',600),
(9,2,'2025-04-09T12:30:00','Scheduled',N'Skin review',700),
(10,1,'2025-04-12T09:00:00','Completed',N'Cardiology review',900);
GO
CREATE VIEW dbo.vw_AppointmentSummary AS
SELECT a.AppointmentID,a.AppointmentDateTime,p.PatientName,d.DoctorName,dep.DepartmentName,
 a.AppointmentStatus,a.Reason,a.FeeCharged
FROM dbo.Appointments a JOIN dbo.Patients p ON p.PatientID=a.PatientID
JOIN dbo.Doctors d ON d.DoctorID=a.DoctorID
JOIN dbo.Departments dep ON dep.DepartmentID=d.DepartmentID;
GO
CREATE PROCEDURE dbo.usp_DoctorSchedule
 @DoctorID INT,
 @StartDate DATE,
 @EndDate DATE
AS
BEGIN
 SET NOCOUNT ON;
 IF @StartDate IS NULL OR @EndDate IS NULL OR @StartDate>@EndDate
   THROW 50002,'Provide a valid date range.',1;
 SELECT * FROM dbo.vw_AppointmentSummary
 WHERE EXISTS (SELECT 1 FROM dbo.Appointments a WHERE a.AppointmentID=vw_AppointmentSummary.AppointmentID AND a.DoctorID=@DoctorID)
 AND AppointmentDateTime>=@StartDate
 AND AppointmentDateTime<DATEADD(DAY,1,@EndDate)
 ORDER BY AppointmentDateTime;
END;
GO
-- 1. Appointment KPIs
SELECT COUNT(*) AS TotalAppointments,
 SUM(CASE WHEN AppointmentStatus='Completed' THEN 1 ELSE 0 END) AS Completed,
 SUM(CASE WHEN AppointmentStatus='Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
 SUM(CASE WHEN AppointmentStatus='No-show' THEN 1 ELSE 0 END) AS NoShows,
 CAST(100.0*SUM(CASE WHEN AppointmentStatus='No-show' THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0) AS DECIMAL(5,2)) AS NoShowPct
FROM dbo.Appointments;
-- 2. Monthly appointment and collected-fee trend
SELECT YEAR(AppointmentDateTime) AS ApptYear,MONTH(AppointmentDateTime) AS ApptMonth,
 COUNT(*) AS AppointmentCount,
 SUM(CASE WHEN AppointmentStatus='Completed' THEN FeeCharged ELSE 0 END) AS CollectedFees
FROM dbo.Appointments GROUP BY YEAR(AppointmentDateTime),MONTH(AppointmentDateTime)
ORDER BY ApptYear,ApptMonth;
-- 3. Doctor workload and completion rate
SELECT d.DoctorName,dep.DepartmentName,COUNT(a.AppointmentID) AS TotalAppointments,
 SUM(CASE WHEN a.AppointmentStatus='Completed' THEN 1 ELSE 0 END) AS CompletedAppointments,
 CAST(100.0*SUM(CASE WHEN a.AppointmentStatus='Completed' THEN 1 ELSE 0 END)/NULLIF(COUNT(a.AppointmentID),0) AS DECIMAL(5,2)) AS CompletionPct
FROM dbo.Doctors d JOIN dbo.Departments dep ON dep.DepartmentID=d.DepartmentID
LEFT JOIN dbo.Appointments a ON a.DoctorID=d.DoctorID
GROUP BY d.DoctorName,dep.DepartmentName ORDER BY TotalAppointments DESC;
-- 4. Fees collected by department (completed visits only)
SELECT dep.DepartmentName,SUM(a.FeeCharged) AS CollectedFees
FROM dbo.Appointments a JOIN dbo.Doctors d ON d.DoctorID=a.DoctorID
JOIN dbo.Departments dep ON dep.DepartmentID=d.DepartmentID
WHERE a.AppointmentStatus='Completed'
GROUP BY dep.DepartmentName ORDER BY CollectedFees DESC;
-- 5. Most common appointment reasons
SELECT TOP 10 Reason,COUNT(*) AS AppointmentCount
FROM dbo.Appointments GROUP BY Reason ORDER BY AppointmentCount DESC,Reason;
-- 6. Patient repeat-visit analysis
SELECT p.PatientID,p.PatientName,COUNT(a.AppointmentID) AS TotalVisits,
 SUM(CASE WHEN a.AppointmentStatus='Completed' THEN 1 ELSE 0 END) AS CompletedVisits
FROM dbo.Patients p JOIN dbo.Appointments a ON a.PatientID=p.PatientID
GROUP BY p.PatientID,p.PatientName HAVING COUNT(a.AppointmentID)>1
ORDER BY TotalVisits DESC;
-- 7. Daily schedule, including status
SELECT * FROM dbo.vw_AppointmentSummary ORDER BY AppointmentDateTime;
-- 8. Stored procedure example
EXEC dbo.usp_DoctorSchedule @DoctorID=1,@StartDate='2025-01-01',@EndDate='2025-04-30';
-- 9. Data-quality checks
SELECT * FROM dbo.Appointments WHERE FeeCharged<0;
SELECT AppointmentDateTime,DoctorID,COUNT(*) AS SameTimeBookings
FROM dbo.Appointments WHERE AppointmentStatus IN ('Scheduled','Completed')
GROUP BY AppointmentDateTime,DoctorID HAVING COUNT(*)>1;
GO
