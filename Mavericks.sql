create database University_HR_ManagementSystem_90;
use University_HR_ManagementSystem_90;

GO
create procedure createAllTables
as 
begin
create table Department(
	name varchar(50)  , -- should we check if it is in MET, IET,.....? If so should we do it for all of the departments in the uni?
	building_location varchar(50),
	check(name in ('MET', 'IET', 'HR department', 'Medical department')),
	constraint PK_DPT primary key (name)
);
create table Employee( 
	employee_ID int identity(1,1) not null, 
	first_name varchar (50), 
	last_name varchar (50), 
	email varchar (50),
	password varchar (50), 
	address varchar (50), 
	gender char (1), 
	official_day_off varchar (50), -- should we check if it is a week day?
	years_of_experience int, 
	national_ID char (16),
	employment_status varchar (50), 
	type_of_contract varchar (50), 
	emergency_contact_name varchar(50), 
	emergency_contact_phone char (11), 
	annual_balance int, 
	accidental_balance int, 
	salary decimal(10,2), -- I do not know how should this be calculated
	hire_date date, 
	last_working_date date, 
	dept_name varchar (50),
	constraint PK_employee Primary key(employee_ID),
	constraint FK_employee_dept foreign key (dept_name) 
	references Department(name),
	check(type_of_contract in ('full_time', 'part_time')),
	check(employment_status in ('onleave', 'notice_period', 'active', 'resigned'))
);

create table Employee_Phone(
	emp_ID int ,
	phone_num char(11),
	constraint PK_PhoneNum primary key(emp_ID, phone_num),
	constraint FK_phone_employee foreign key (emp_ID) references Employee(employee_ID)
);
create table Role (
	role_name varchar (50) not null, -- what about the HR representative format?
	title varchar (50),
	description varchar (50), 
	rank int, 
	base_salary decimal (10,2), 
	percentage_YOE decimal (4,2), 
	percentage_overtime decimal (4,2), 
	annual_balance int, 
	accidental_balance int,
	constraint PK_Role primary key (role_name)
);
create table Employee_Role (
	emp_ID int, 
	role_name varchar(50),
	constraint PK_Employee_Role primary key (emp_ID, role_name),
	constraint FK_Employee_Role foreign key (emp_ID) references Employee(employee_ID),
	constraint FK_Role foreign key (role_name) references Role(role_name)
);
create table Role_existsIn_Department (
	department_name varchar(50), 
	Role_name varchar(50),
	constraint PK_ReD primary key (department_name, Role_name),
	constraint FK_Role_Exist foreign key (role_name) references Role(role_name),
	constraint FK_role_dept foreign key (department_name) references Department(name)
);
create table Leave (
	request_ID int identity(1,1), 
	date_of_request date,
	start_date date,
	end_date date, 
	num_days  as datediff(day, end_date, start_date), 
	final_approval_status varchar (50) default 'pending',
	check(final_approval_status in ('pending', 'approved', 'rejected')),
	constraint PK_Leave primary key (request_ID)
	);

create table Annual_Leave (
	request_ID int, 
	emp_ID int , 
	replacement_emp int,
	constraint PK_Leave_Annual primary key (request_ID),
	constraint FK_Leave_Annual foreign key (request_ID) references Leave(request_ID),
	constraint FK_Employee_Annual foreign key (emp_ID) references Employee(employee_ID),
	constraint FK_Employee2_Annual foreign key (replacement_emp) references Employee(employee_ID)

	);
create table Accidental_Leave (
	request_ID int,
	emp_ID int,
	constraint PK_Leave_acc primary key (request_ID),
	constraint FK_Leave_acc foreign key (request_ID) references Leave(request_ID),
	constraint FK_Employee_acc foreign key (emp_ID) references Employee(employee_ID)
);
create table Medical_Leave (
	request_ID int ,
	insurance_status BIT, 
	disability_details varchar (50), 
	type varchar (50), 
	Emp_ID int,
	constraint PK_Leave_med primary key (request_ID),
	constraint FK_Leave_med foreign key (request_ID) references Leave(request_ID),
	constraint FK_Employee_med foreign key (Emp_ID) references Employee(employee_ID),
	check (type in ('sick', 'maternity'))
);
create table Unpaid_Leave (
	request_ID int ,
	Emp_ID int ,
	constraint PK_Leave_unpaid primary key (request_ID),
	constraint FK_Leave_unpaid foreign key (request_ID) references Leave(request_ID),
	constraint FK_Employee_unpaid foreign key (Emp_ID) references Employee(employee_ID)
);
create table Compensation_Leave (
	request_ID int, 
	reason varchar (50), 
	date_of_original_workday date, 
	emp_ID int,
	replacement_emp int,
	constraint PK_Leave_comp primary key (request_ID),
	constraint FK_Leave_comp foreign key (request_ID) references Leave(request_ID),
	constraint FK_Employee_comp foreign key (emp_ID) references Employee(employee_ID),
	constraint FK_Employee2_comp foreign key (replacement_emp) references Employee(employee_ID)
);
create table Document (
	document_ID int identity(1,1), 
	type varchar (50), 
	description varchar (50), 
	file_name varchar (50), 
	creation_date date, 
	expiry_date date, 
	status varchar (50), 
	emp_ID int, 
	medical_ID int, 
	unpaid_ID int,
	check(status in ('valid', 'expired')),
	check(type in ('contract', 'medical report', 'national ID')), -- not sure of this
	constraint PK_Doc primary key (document_ID),
	constraint FK_Employee_Doc foreign key (emp_ID) references Employee(employee_ID),
	constraint FK_MED_Doc foreign key (medical_ID) references Medical_Leave(request_ID),
	constraint FK_UnPaid_doc foreign key (unpaid_ID) references Unpaid_Leave(request_ID)
);
create table Payroll (
	ID int identity(1,1), 
	payment_date date, 
	final_salary_amount decimal (10,1), 
	from_date date, 
	to_date date, 
	comments varchar (150), 
	bonus_amount decimal (10,2), 
	deductions_amount decimal (10,2), 
	emp_ID int,
	constraint PK_Payroll primary key (ID),
	constraint FK_Employee_pay foreign key (emp_ID) references Employee(employee_ID)
);
create table Attendance (
	attendance_ID int identity(1,1), 
	date date, 
	check_in_time time, 
	check_out_time time, 
	total_duration AS DATEDIFF(hour, check_in_time, check_out_time),
	status varchar (50) default 'Absent',
	emp_ID int,
	constraint PK_att primary key (attendance_ID),
	constraint FK_Employee_att foreign key (emp_ID) references Employee(employee_ID),
	check(status in ('Absent', 'attended'))
	)  ;
create table Deduction (
	deduction_ID int identity(1,1), 
	emp_ID int, 
	date date,
	amount decimal (10,2), 
	type varchar (50), 
	status varchar (50) default 'pending', 
	unpaid_ID int, 
	attendance_ID int,
	constraint PK_Deduction primary key (deduction_ID, emp_ID),
	constraint FK_Employee_ded foreign key (emp_ID) references Employee(employee_ID),
	constraint FK_unpaid_ded foreign key (unpaid_ID) references Unpaid_Leave(request_ID),
	constraint FK_att_ded foreign key (attendance_ID) references Attendance(attendance_ID),
	check (status in ('pending', 'finalized')),
	check (type in ('unpaid', 'missing_hours', 'missing_days'))
);
create table Performance (
	performance_ID int identity(1,1),
	rating int, 
	comments varchar(50), 
	semester char (3), 
	emp_ID int,
	constraint PK_Perform primary key (performance_ID),
	constraint FK_Employee_perform foreign key (emp_ID) references Employee(employee_ID),
	check(rating >=1 and rating <= 5)
);
create table Employee_Replace_Employee (
	Emp1_ID int, 
	Emp2_ID int, 
	from_date date, 
	to_date date,
	constraint PK_Replace primary key (Emp1_ID, Emp2_ID),
	constraint FK_Employee1_replace foreign key (Emp1_ID) references Employee(employee_ID)	,
	constraint FK_Employee2_replace foreign key (Emp2_ID) references Employee(employee_ID)	
);
create table Employee_Approve_Leave (
	Emp1_ID int , 
	Leave_ID int ,
	status varchar (50), -- should we check anything about this?
	constraint PK_App_Leave primary key (Emp1_ID, Leave_ID),
	constraint FK_Employee1_App_leave foreign key (Emp1_ID) references Employee(employee_ID)	
);
end
GO

Exec createAllTables;

GO
create procedure dropAllTables
as
begin

	drop table Employee_Approve_Leave;
	drop table Employee_Replace_Employee;
	drop table Performance;
	drop table Deduction;
	drop table Attendance;
	drop table Payroll;
	drop table Document;
	drop table Compensation_Leave;
	drop table Unpaid_Leave;
	drop table Medical_Leave;
	drop table Accidental_Leave;
	drop table Annual_Leave;
	drop table Leave;
	drop table Employee_Role;
	drop table Role_existsIn_Department;
	drop table Employee_Phone;
	drop table Employee;
	drop table Role;
	drop table Department;
end
GO

Exec dropAllTables;

GO
create procedure allEmployeeProfiles
as
begin
select employee_ID as ID, first_name as [First Name], last_name as [Last Name], gender, email, address, years_of_experience as [Years of Experience],
official_day_off as [Official Day Off], type_of_contract as [Type Of Contract],employment_status as [Employment Status], 
annual_balance as [Annual Balance], accidental_balance as [Accidental Balance] from Employee;
end
GO

Exec allEmployeeProfiles;

GO
create procedure clearAllTables
as
begin
	TRUNCATE TABLE Employee_Approve_Leave;
	TRUNCATE TABLE Employee_Replace_Employee;
	TRUNCATE TABLE Performance;
	TRUNCATE TABLE Deduction;
	TRUNCATE TABLE Attendance;
	TRUNCATE TABLE Payroll;
	TRUNCATE TABLE Document;
	TRUNCATE TABLE Compensation_Leave;
	TRUNCATE TABLE Unpaid_Leave;
	TRUNCATE TABLE Medical_Leave;
	TRUNCATE TABLE Accidental_Leave;
	TRUNCATE TABLE Annual_Leave;
	TRUNCATE TABLE Leave;
	TRUNCATE TABLE Employee_Role;
	TRUNCATE TABLE Role_existsIn_Department;
	TRUNCATE TABLE Employee_Phone;
	TRUNCATE TABLE Employee;
	TRUNCATE TABLE Role;
	TRUNCATE TABLE Department;
end
GO

GO
create view NoEmployeeDept
as 
select d.name, count(e.employee_ID) as [Numbers of Employee/Department]
from Department d left join Employee e on d.name=e.dept_name
group by d.name
GO

--2.3.A
create procedure Update_Status_Doc
as
begin
	update Document
	set status = 'expired'
	where expiry_date < cast(CURRENT_TIMESTAMP as date) and status = 'valid';  -- is it to make all expired valid or vice versa?
end
GO

exec update_Status_Doc


--2.3.B
GO
create procedure Remove_Deductions
as 
begin
update Deduction
set amount=0
from Deduction d inner join Employee e on e.employee_ID = d.emp_ID 
where e.employment_status = 'resigned'
end
GO

--2.2.C
CREATE VIEW	allPerformance AS
SELECT *
FROM Performance 
WHERE semester LIKE 'W%';
GO

--2.2.D
CREATE VIEW allRejectedMedicals AS
SELECT Medical_Leave.*
FROM Medical_Leave
INNER JOIN Leave ON Leave.request_ID = Medical_Leave.request_ID
WHERE Leave.final_approval_status = 'rejected';
GO

--2.3.F
CREATE PROCEDURE Intitiate_Attendance AS
INSERT INTO Attendance(date,emp_ID)
SELECT CAST(GETDATE() AS DATE),employee_ID
FROM Employee;
GO

--2.3.G
CREATE PROCEDURE Update_Attendance @Employee_id int, @check_in time, @check_out time AS 
	UPDATE Attendance
	SET check_in_time = @check_in, check_out_time= @check_out, status='attended'
	WHERE emp_ID = @Employee_id AND date=CAST(GETDATE() AS DATE);
GO

--2.3.I
CREATE PROCEDURE Remove_DayOff @Employee_id int AS -- should we check if the attendance status is 'Absent'?
with tmp as (select emp_ID, official_day_off from Employee where emp_ID = @Employee_id)
Delete from Attendance
where emp_ID = @Employee_id and tmp.employee_ID = @Employee_id and DATENAME(WEEKDAY, date) = tmp.official_day_off;
GO

--2.3.J
CREATE PROCEDURE Remove_Approved_Leaves 
    @Employee_id INT
AS
BEGIN
    DELETE FROM Attendance
    WHERE emp_ID = @Employee_id
      AND EXISTS (
            SELECT 1
            FROM Leave l
            LEFT JOIN Annual_Leave al ON al.request_ID = l.request_ID
            LEFT JOIN Accidental_Leave ac ON ac.request_ID = l.request_ID
            LEFT JOIN Medical_Leave ml ON ml.request_ID = l.request_ID
            LEFT JOIN Compensation_Leave cl ON cl.request_ID = l.request_ID
            LEFT JOIN Unpaid_Leave ul ON ul.request_ID = l.request_ID
            WHERE l.final_approval_status = 'approved'
              AND (al.emp_ID = @Employee_id
                OR ac.emp_ID = @Employee_id
                OR ml.Emp_ID = @Employee_id
                OR cl.emp_ID = @Employee_id
                OR ul.Emp_ID = @Employee_id)
              AND Attendance.date BETWEEN l.start_date AND l.end_date
        );
END
GO

--2.3.K
CREATE PROCEDURE  Replace_employee 
	@Emp1_ID INT,
	@Emp2_ID INT,
	@From_Date DATE,
	@To_Date DATE
AS 
BEGIN 
	INSERT INTO Employee_Replace_Employee (Emp1_ID, Emp2_ID, from_date, to_date)
	VALUES (@Emp1_ID, @Emp2_ID, @From_Date, @To_Date);
END
GO

--2.3.D
GO
create procedure Create_Holiday
as
begin
create Table Holiday (
holiday_id int identity(1,1) primary key,
name varchar (50),
from_date date,
to_date date
);
end
GO

--2.3.E
GO
create procedure Add_Holiday @holiday_name varchar(50), @from_date date, @to_date date
as 
begin 
insert into Holiday values( @holiday_name, @from_date, @to_date)
end 
GO

exec Create_Holiday
exec Add_Holiday

--2.3.H
GO
create procedure Remove_Holiday
as
begin
delete Attendance from Attendance A inner join Holiday H on A.date between H.from_date and H.to_date
end
GO

exec Remove_Holiday

--2.2.E
GO
create view allEmployeeAttendance 
as 
select a.*, e.first_name, e.last_name from Attendance a inner join Employee e on a.emp_ID =e.employee_ID
where a.date = cast(current_Timestamp -1 as date)
GO

--2.4.D
GO
create or alter procedure HR_approval_comp @request_ID int, @HR_ID int -- how to do it
as 
begin 
UPDATE Leave
	SET final_approval_status = 
		CASE 
			WHEN final_approval_status = 'approved' THEN 'rejected'
			WHEN final_approval_status = 'rejected' THEN 'approved'
			ELSE 'approved'
		END
	WHERE request_ID = @request_ID and exists (select E.employee_ID from Employee E join Department D on E.dept_name = D.name where E.employee_ID =@HR_ID
	and  D.name= 'HR department' )
end
GO

--2.5.B
GO
create function MyPerformance (@employee_ID int, @semester char(3))
returns table
as
return
(
select e.first_name, e.last_name, p.* from Employee e join Performance p on e.employee_ID = p.performance_ID 
where e.employee_ID = @employee_ID and p.semester = @semester
)
GO


--2.5.C
GO
CREATE FUNCTION MyAttendance(@employee_ID int)
RETURNS TABLE
AS
RETURN
(
    SELECT A.date, A.check_in_time, A.check_out_time, A.total_duration, A.status
    FROM Attendance A
    INNER JOIN Employee E ON A.emp_ID = E.employee_ID
    WHERE A.emp_ID = @employee_ID
   
    AND MONTH(A.date) = MONTH(GETDATE())
   
  
    AND NOT (DATENAME(weekday, A.date) = E.official_day_off AND A.status = 'Absent')
)
GO


--2.5.D
GO
create function Last_month_payroll (@employee_ID int)
returns table
as
return
(
select e.first_name, e.last_name, p.* from Employee e join Payroll p on e.employee_ID = p.emp_ID
where e.employee_ID= @employee_ID  and month(p.payment_date) = month(DATEADD(month, -1, GETDATE()))
    and year(p.payment_date) = year(DATEADD(month, -1, GETDATE()))
)
GO
