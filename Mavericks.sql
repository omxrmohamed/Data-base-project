create database University_HR_ManagementSystem_90;
use University_HR_ManagementSystem_90;
drop database University_HR_ManagementSystem_90;

GO
create procedure createAllTables
as 
begin
create table Department(
	name varchar(50)  , -- should we check if it is in MET, IET,.....? If so should we do it for all of the departments in the uni?
	building_location varchar(50),
	check(name in ('MET', 'IET', 'BI','HR', 'Medical')),
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
	official_day_off varchar (50), 
	years_of_experience int, 
	national_ID char (16),
	employment_status varchar (50), 
	type_of_contract varchar (50), 
	emergency_contact_name varchar(50), 
	emergency_contact_phone char (11), 
	annual_balance int, 
	accidental_balance int, 
	salary as calculate_salary(employee_ID),
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
	num_days  as datediff(day, start_date, end_date) + 1, 
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
	check(type in ('contract', 'medical report', 'national ID', 'Memo')), -- not sure of this
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
	check(status in ('absent', 'attended'))
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
	Table_ID int identity(1,1), 
	Emp1_ID int, 
	Emp2_ID int, 
	from_date date, 
	to_date date,
	constraint PK_Replace primary key (Table_ID, Emp1_ID, Emp2_ID),
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

go
CREATE FUNCTION calculate_salary(@emp_ID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE 
        @base_sal DECIMAL(10,2),
        @yoe_percentage DECIMAL(4,2),
        @yoe INT,
        @res DECIMAL(10,2);


    SELECT TOP 1
        @base_sal = R.base_salary,
        @yoe_percentage = R.percentage_YOE,
        @yoe = E.years_of_experience
    FROM Employee E
    JOIN Employee_Role ER ON E.employee_ID = ER.emp_ID
    JOIN Role R ON R.role_name = ER.role_name
    WHERE E.employee_ID = @emp_ID
    ORDER BY R.rank ASC;  


    SET @res = @base_sal + (@base_sal * @yoe_percentage * @yoe);

    RETURN @res;
END
GO


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
CREATE PROCEDURE dropAllProceduresFunctionsViews
AS
BEGIN
    -- 1. DROP PROCEDURES    
    DROP PROCEDURE IF EXISTS createAllTables;
    DROP PROCEDURE IF EXISTS dropAllTables;
    DROP PROCEDURE IF EXISTS clearAllTables;
    DROP PROCEDURE IF EXISTS allEmployeeProfiles;
    DROP PROCEDURE IF EXISTS Update_Status_Doc;
    DROP PROCEDURE IF EXISTS Remove_Deductions;
    DROP PROCEDURE IF EXISTS Intitiate_Attendance;
    DROP PROCEDURE IF EXISTS Update_Attendance;
    DROP PROCEDURE IF EXISTS Remove_DayOff;
    DROP PROCEDURE IF EXISTS Remove_Approved_Leaves;
    DROP PROCEDURE IF EXISTS Replace_employee;
    DROP PROCEDURE IF EXISTS Create_Holiday;
    DROP PROCEDURE IF EXISTS Add_Holiday;
    DROP PROCEDURE IF EXISTS Remove_Holiday;
    DROP PROCEDURE IF EXISTS Update_Employment_Status;
    DROP PROCEDURE IF EXISTS HR_approval_an_acc;
    DROP PROCEDURE IF EXISTS HR_approval_unpaid;
    DROP PROCEDURE IF EXISTS HR_approval_comp;
    DROP PROCEDURE IF EXISTS Deduction_hours;
    DROP PROCEDURE IF EXISTS Deduction_days;
    DROP PROCEDURE IF EXISTS Deduction_unpaid;
    DROP PROCEDURE IF EXISTS Add_Payroll;
    DROP PROCEDURE IF EXISTS Submit_annual;
    DROP PROCEDURE IF EXISTS Upperboard_approve_annual;
    DROP PROCEDURE IF EXISTS Submit_accidental;
    DROP PROCEDURE IF EXISTS Submit_medical;
    DROP PROCEDURE IF EXISTS Submit_unpaid;
    DROP PROCEDURE IF EXISTS Upperboard_approve_unpaids;
    DROP PROCEDURE IF EXISTS Submit_compensation;
    DROP PROCEDURE IF EXISTS Dean_andHR_Evaluation;
    -- 2. DROP VIEWS
    DROP VIEW IF EXISTS NoEmployeeDept;
    DROP VIEW IF EXISTS allPerformance;
    DROP VIEW IF EXISTS allRejectedMedicals;
    DROP VIEW IF EXISTS allEmployeeAttendance;
    -- 3. DROP FUNCTIONS
    DROP FUNCTION IF EXISTS calculate_salary;
    DROP FUNCTION IF EXISTS HRLoginValidation;
    DROP FUNCTION IF EXISTS EmployeeLoginValidation;
    DROP FUNCTION IF EXISTS Bonus_amount;
    DROP FUNCTION IF EXISTS MyPerformance;
    DROP FUNCTION IF EXISTS MyAttendance;
    DROP FUNCTION IF EXISTS Last_month_payroll;
    DROP FUNCTION IF EXISTS Deductions_Attendance;
    DROP FUNCTION IF EXISTS Is_On_Leave;
    DROP FUNCTION IF EXISTS Status_leaves;

END
GO

exec dropAllProceduresFunctionsViews

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

GO
--2.3.C
CREATE PROCEDURE Update_Employment_Status (
@employee_ID INT
)
AS
BEGIN
DECLARE @isOnLeave BIT;
SET @isOnLeave = dbo.Is_On_Leave(
@employee_ID, 
CAST(CURRENT_TIMESTAMP AS DATE), 
CAST(CURRENT_TIMESTAMP AS DATE)
);

IF @isOnLeave = 1
BEGIN
UPDATE Employee 
SET employment_status = 'onleave' 
WHERE employee_ID = @employee_ID;
END
ELSE
BEGIN
UPDATE Employee 
SET employment_status = 'active'
WHERE employee_ID = @employee_ID;
END
END
GO

-- 2.4.A
GO
create function HRLoginValidation (@employee_ID int, @password varchar(50))
returns bit
as 
begin
DECLARE @isValid BIT;
if exists( select * from Employee  where employee_ID = @employee_ID and password = @password) and 
	exists(select E.employee_ID from Employee E join Department D on E.dept_name = D.name where E.employee_ID =@HR_ID
	and  D.name= 'HR')
begin
	set @isValid = 1
end
else 
begin
	set @isValid = 0
end
return @isValid
end
GO


-- 2.4.B
GO
create procedure  HR_approval_an_acc @request_ID int, @HR_ID int
as
begin 
	declare @nd int
	set @nd = (select num_days from leave where request_ID = @request_ID)
	if exists(select * from Accidental_Leave al join Employee e on al.emp_ID = e.employee_ID
				where e.accidental_balance > 0 and request_ID = @request_ID)

				begin 
			update leave 
				 SET final_approval_status = 
					CASE 
						WHEN final_approval_status = 'approved' THEN 'rejected'
						WHEN final_approval_status = 'rejected' THEN 'approved'
						ELSE 'approved'
					END
					where request_ID = @request_ID and exists (select E.employee_ID from Employee E join Department D on E.dept_name = D.name where E.employee_ID =@HR_ID
					and  D.name= 'HR');
			update Employee
			set accidental_balance = accidental_balance - @nd
			where employee_ID = (select emp_ID from Accidental_Leave where request_ID = @request_ID);
			end
	else if exists(select * from Annual_Leave al join Employee e on al.emp_ID = e.employee_ID
				where e.annual_balance > 0 and request_ID = @request_ID)
				begin
				update leave 
				 SET final_approval_status = 
					CASE 
						WHEN final_approval_status = 'approved' THEN 'rejected'
						WHEN final_approval_status = 'rejected' THEN 'approved'
						ELSE 'approved'
					END
					where request_ID = @request_ID and exists (select E.employee_ID from Employee E join Department D on E.dept_name = D.name where E.employee_ID =@HR_ID
					and  D.name= 'HR');
					update Employee
					set annual_balance = annual_balance - @nd
					where employee_ID = (select emp_ID from Annual_Leave where request_ID = @request_ID);
				end
end
GO


--2.4.C
GO
create procedure HR_approval_unpaid @request_ID int, @HR_ID int
as
begin
	update l 
		 SET l.final_approval_status = 
					CASE 
						when e.type_of_contract <> 'full_time' then 'rejected'
                        when l.num_days>30 then 'rejected'
                        when EXISTS (
                    SELECT 1 
                    FROM Employee_Approve_Leave 
                    WHERE Leave_ID = @request_ID AND status = 'rejected'
                                     ) THEN 'rejected'
                    when exists ( select 1 from Leave where l.final_approval_status = 'approved' 
                    and year(l.date_of_request) = year(l.start_date) and l.request_ID = @request_ID) then 'rejected'
                      
					END
        from Leave l join Unpaid_Leave ul on l.request_ID = ul.Emp_ID inner join Employee e on e.employee_ID = ul.Emp_ID
		where request_ID = @request_ID and l.final_approval_status ='pending' 
        and exists (select 1 from Employee e where e.employee_ID= @HR_ID and e.dept_name = 'HR')
end
GO


--2.4.D
GO
create or alter procedure HR_approval_comp @request_ID int, @HR_ID int 
as 
begin 
update l 
set l.final_approval_status= 
case 
when cl.reason is null or cl.replacement_emp is null then 'rejected'
when (month(l.date_of_request) <> month(cl.date_of_original_workday)) or (year(l.date_of_request) <> year(cl.date_of_original_workday)) then 'rejected'
when EXISTS (
                SELECT 1 
                FROM Employee_Approve_Leave eal
                WHERE eal.Leave_ID = @request_ID
                  AND status = 'rejected'
            ) THEN 'rejected'
when E.official_day_off <> DATENAME(WEEKDAY, cl.date_of_original_workday) or 
( E.official_day_off = DATENAME(WEEKDAY, cl.date_of_original_workday) and A.total_duration<8) then 'rejected'  
else 'approved'
end
from (Leave l join Compensation_Leave cl on l.request_ID= cl.request_ID) inner join Employee E on E.employee_ID = cl.emp_ID
inner join Attendance A on A.emp_ID = cl.emp_ID and A.date = cl.date_of_original_workday
where cl.request_ID = @request_ID and  l.final_approval_status ='pending' 
and exists (select 1 from Employee e where e.employee_ID= @HR_ID and e.dept_name = 'HR')
end
GO


--2.5.A
GO
create function EmployeeLoginValidation (@employee_ID INT, @password VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @isValid BIT;

	IF EXISTS (
		SELECT 1 
		FROM Employee 
		WHERE employee_ID = @employee_ID 
		  AND password = @password
		  AND employment_status = 'active'
	)
	BEGIN
		SET @isValid = 1;
	END
	ELSE
	BEGIN
		SET @isValid = 0;
	END

	RETURN @isValid;
END
GO

--2.4.E
CREATE PROCEDURE Deduction_hours
    @employee_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @attendance_id INT,
            @date DATE,
            @hours INT,
            @missing_hours INT,
            @salary DECIMAL(10,2),
            @rate_per_hour DECIMAL(10,4),
            @amount DECIMAL(10,2);

    SELECT TOP 1
        @attendance_id = attendance_ID,
        @date = date,
        @hours = total_duration
    FROM Attendance
    WHERE emp_ID = @employee_ID
      AND status = 'attended'            
      AND total_duration < 8              
      AND total_duration IS NOT NULL
      AND MONTH(date) = MONTH(GETDATE())
      AND YEAR(date) = YEAR(GETDATE())
    ORDER BY date ASC;                   


    IF @attendance_id IS NULL
        RETURN;

    SET @missing_hours = 8 - @hours;

    SELECT @salary = salary
    FROM Employee
    WHERE employee_ID = @employee_ID;


    SET @rate_per_hour = (@salary / 22) / 8;
    SET @amount = @missing_hours * @rate_per_hour;


    INSERT INTO Deduction (emp_ID, date, amount, type, status, unpaid_ID, attendance_ID)
    VALUES (@employee_ID, @date, @amount, 'missing_hours', 'pending', NULL, @attendance_id);
END
GO

--2.4.F
GO
create or alter procedure Deduction_days @employee_ID int
as 
begin
declare @salary decimal(10,2), @rateperday decimal(10,2)

select @salary = E.salary from Employee E where E.employee_ID = @employee_ID 
set @rateperday = (@salary / 22.0)
insert into Deduction (emp_ID, date, amount, type, status, attendance_ID)
(
 SELECT
 A.emp_id, A.date, @rateperday, 'missing_days', 'pending', A.attendance_ID
 from Attendance A where A.emp_ID = @employee_ID and A.status = 'absent' and not exists (select 1 from Deduction D where A.attendance_ID = D.attendance_ID)
 );
 end 
GO


--2.4.G
CREATE PROCEDURE Deduction_unpaid
    @employee_ID int
AS
BEGIN
    DECLARE @daily_rate decimal(10,2); -- This is an assumption that daily rate is calculated same as rate per hour in 1.3 I couldn't find anywhere how to calculate day rate or missing day rate 
	SELECT @daily_rate = (salary / 22.0)
    FROM Employee 
    WHERE employee_ID = @employee_ID;

    INSERT INTO Deduction (emp_ID, date, amount, type, status, unpaid_ID)
    SELECT 
        @employee_ID,
        CASE 
            WHEN MONTH(L.start_date) != MONTH(L.end_date) THEN EOMONTH(L.start_date)
            ELSE L.end_date 
        END,
        (DATEDIFF(day, L.start_date, 
            CASE 
                WHEN MONTH(L.start_date) != MONTH(L.end_date) THEN EOMONTH(L.start_date)
                ELSE L.end_date 
            END
        ) + 1) * @daily_rate,
        'unpaid', 
        'pending', 
        L.request_ID
    FROM Unpaid_Leave UL
    INNER JOIN Leave L ON UL.request_ID = L.request_ID
    WHERE UL.Emp_ID = @employee_ID
      AND L.final_approval_status = 'approved' AND  NOT EXISTS (
          SELECT 1 FROM Deduction D 
          WHERE D.unpaid_ID = L.request_ID 
          AND MONTH(D.date) = MONTH(L.start_date)
      )
    UNION ALL
    SELECT 
        @employee_ID,
        L.end_date,
        (DATEDIFF(day, DATEADD(day, 1, EOMONTH(L.start_date)), L.end_date) + 1) * @daily_rate,
        'unpaid', 
        'pending', 
        L.request_ID
    FROM Unpaid_Leave UL
    INNER JOIN Leave L ON UL.request_ID = L.request_ID
    WHERE UL.Emp_ID = @employee_ID
      AND L.final_approval_status = 'approved'
      AND MONTH(L.start_date) != MONTH(L.end_date) 
      AND NOT EXISTS (
          SELECT 1 FROM Deduction D 
          WHERE D.unpaid_ID = L.request_ID 
          AND MONTH(D.date) = MONTH(L.end_date)
      );
END
GO
--2.4.H
CREATE FUNCTION Bonus_amount (@employee_ID int)
RETURNS decimal(10,2)
AS
BEGIN
    DECLARE @bonus decimal(10,2) = 0;
    DECLARE @salary decimal(10,2);
    DECLARE @overtime_factor decimal(4,2);
    DECLARE @hourly_rate decimal(10,2);
    DECLARE @total_extra_hours int; 

    SELECT 
        @salary = E.salary,
        @overtime_factor = R.percentage_overtime
    FROM Employee E
    INNER JOIN Employee_Role ER ON E.employee_ID = ER.emp_ID
    INNER JOIN Role R ON ER.role_name = R.role_name
    WHERE E.employee_ID = @employee_ID;

    IF @salary IS NULL RETURN 0;

    SET @hourly_rate = (@salary / 22.0) / 8.0;

    SELECT @total_extra_hours = SUM(total_duration - 8)
    FROM Attendance
    WHERE emp_ID = @employee_ID
      AND total_duration > 8
      AND status = 'attended';

    SET @bonus = @hourly_rate * ((@overtime_factor * @total_extra_hours) / 100.0);

    RETURN @bonus;
END
GO

--2.4.I
CREATE PROCEDURE Add_Payroll
    @employee_ID int,
    @from_date date,
    @to_date date
AS
BEGIN
	DECLARE @base_salary decimal(10,2)= 0;
    DECLARE @bonus_val decimal(10,2)= 0;
    DECLARE @deduction_val decimal(10,2)= 0;
    DECLARE @final_salary decimal(10,1)= 0;

	SELECT @base_salary = salary 
	FROM Employee 
	WHERE employee_ID = @employee_ID;

	SET @bonus_val = dbo.Bonus_amount(@employee_ID);

	SELECT @deduction_val = SUM(amount)
	FROM Deduction
	WHERE emp_ID = @employee_ID AND (date BETWEEN @from_date AND @to_date) AND status = 'pending';

	UPDATE Deduction
        SET status = 'finalized'
        WHERE emp_ID = @employee_ID AND (date BETWEEN @from_date AND @to_date) AND status = 'pending';
	
	SET @final_salary = (@base_salary + @bonus_val) - @deduction_val;

	INSERT INTO Payroll (
            payment_date, 
            final_salary_amount, 
            from_date, 
            to_date, 
            comments, 
            bonus_amount, 
            deductions_amount, 
            emp_ID)
	VALUES (
            GETDATE(),
            @final_salary, 
            @from_date, 
            @to_date, 
            'Monthly Salary Generated', 
            @bonus_val, 
            @deduction_val, 
            @employee_ID
        );
	END
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
	AND YEAR(A.date) = YEAR(GETDATE())
    AND NOT (DATENAME(weekday, A.date) = E.official_day_off AND A.status = 'Absent')
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

--2.5.E
GO
create function Deductions_Attendance(@employee_ID int, @month int)
returns table
as 
return select d.* from Deduction d inner join Attendance a on d.attendance_ID = a.attendance_ID
where d.emp_ID = @employee_ID and month(a.date) = @month
Go

--2.5.F
CREATE FUNCTION Is_On_Leave (
@employee_ID INT,
@from_date DATE,
@to_date DATE
)
RETURNS BIT
AS
BEGIN
DECLARE @IsOnLeave BIT = 0;

IF EXISTS (
SELECT 1
FROM Leave L
INNER JOIN (
SELECT request_ID, emp_ID FROM Annual_Leave
UNION
SELECT request_ID, emp_ID FROM Accidental_Leave
UNION
SELECT request_ID, Emp_ID FROM Medical_Leave
UNION
SELECT request_ID, Emp_ID FROM Unpaid_Leave
) AS X
ON L.request_ID = X.request_ID
WHERE X.emp_ID = @employee_ID
AND (L.final_approval_status = 'approved'
OR L.final_approval_status = 'pending')
AND L.start_date <= @to_date
AND L.end_date >= @from_date
)
BEGIN
SET @IsOnLeave = 1;
END

RETURN @IsOnLeave;
END
GO
go

--2.5.G
CREATE PROCEDURE Submit_annual
    @employee_ID INT,
    @replacement_emp INT,
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [Leave] (date_of_request, start_date, end_date, final_approval_status)
    VALUES (CAST(GETDATE() AS DATE), @start_date, @end_date, 'pending');

    DECLARE @req_id INT = SCOPE_IDENTITY();

    INSERT INTO Annual_Leave (request_ID, emp_ID, replacement_emp)
    VALUES (@req_id, @employee_ID, @replacement_emp);
    DECLARE @dept_name varchar(50);
    DECLARE @role_name varchar(50);

    SELECT @dept_name = dept_name FROM Employee WHERE employee_ID = @employee_ID;
    SELECT TOP 1 @role_name = R.role_name 
    FROM Employee_Role ER 
    JOIN Role R ON ER.role_name = R.role_name
    WHERE ER.emp_ID = @employee_ID
    ORDER BY R.rank ASC;

    DECLARE @president_ID int, @hr_mgr_ID int, @hr_rep_ID int, @dean_ID int;
    SELECT TOP 1 @president_ID = ER.emp_ID FROM Employee_Role ER WHERE ER.role_name = 'President';
    SELECT TOP 1 @hr_mgr_ID = ER.emp_ID FROM Employee_Role ER WHERE ER.role_name = 'HR Manager';
    SELECT TOP 1 @hr_rep_ID = ER.emp_ID FROM Employee_Role ER WHERE ER.role_name = 'HR Representative';
    IF @role_name IN ('Dean', 'Vice Dean')
    BEGIN
        INSERT INTO Employee_Approve_Leave VALUES (@president_ID, @req_id, 'pending');
        INSERT INTO Employee_Approve_Leave VALUES (@hr_rep_ID, @req_id, 'pending');
    END
    ELSE IF @dept_name = 'HR department'
    BEGIN
        INSERT INTO Employee_Approve_Leave VALUES (@president_ID, @req_id, 'pending');
        INSERT INTO Employee_Approve_Leave VALUES (@hr_mgr_ID, @req_id, 'pending');
    END
    ELSE
    BEGIN
        SELECT TOP 1 @dean_ID = ER.emp_ID
        FROM Employee E JOIN Employee_Role ER ON E.employee_ID = ER.emp_ID
        WHERE ER.role_name = 'Dean' AND E.dept_name = @dept_name;

        IF @dean_ID IS NOT NULL
            INSERT INTO Employee_Approve_Leave VALUES (@dean_ID, @req_id, 'pending');
        
        INSERT INTO Employee_Approve_Leave VALUES (@hr_rep_ID, @req_id, 'pending');
        INSERT INTO Employee_Approve_Leave VALUES (@hr_mgr_ID, @req_id, 'pending');
    END
END
GO

--2.5.H
CREATE FUNCTION Status_leaves(@employee_ID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT L.request_ID, L.date_of_request, L.final_approval_status AS status
    FROM [Leave] L
    WHERE (
            L.request_ID IN (SELECT request_ID FROM Annual_Leave WHERE emp_ID = @employee_ID)
            OR
            L.request_ID IN (SELECT request_ID FROM Accidental_Leave WHERE emp_ID = @employee_ID)
          )
      AND MONTH(L.date_of_request) = MONTH(GETDATE())
      AND YEAR(L.date_of_request) = YEAR(GETDATE())
);
GO

--2.5.I
CREATE PROCEDURE Upperboard_approve_annual
    @request_ID INT,
    @Upperboard_ID INT,
    @replacement_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Annual_Leave SET replacement_emp = @replacement_ID WHERE request_ID = @request_ID;

    DECLARE @app_emp INT;
    DECLARE @start DATE, @end DATE;

    SELECT @app_emp = emp_ID FROM Annual_Leave WHERE request_ID = @request_ID;
    SELECT @start = start_date, @end = end_date FROM [Leave] WHERE request_ID = @request_ID;

    DECLARE @app_dept varchar(50), @rep_dept varchar(50);
    SELECT @app_dept = dept_name FROM Employee WHERE employee_ID = @app_emp;
    SELECT @rep_dept = dept_name FROM Employee WHERE employee_ID = @replacement_ID;

    DECLARE @replacement_busy BIT = 0;
    IF EXISTS (
        SELECT 1 FROM [Leave] L
        JOIN (
            SELECT request_ID FROM Annual_Leave WHERE emp_ID = @replacement_ID
            UNION ALL SELECT request_ID FROM Accidental_Leave WHERE emp_ID = @replacement_ID
            UNION ALL SELECT request_ID FROM Medical_Leave WHERE Emp_ID = @replacement_ID
            UNION ALL SELECT request_ID FROM Unpaid_Leave WHERE Emp_ID = @replacement_ID
            UNION ALL SELECT request_ID FROM Compensation_Leave WHERE emp_ID = @replacement_ID
        ) R ON L.request_ID = R.request_ID
        WHERE L.final_approval_status IN ('approved', 'pending')
        AND (L.start_date <= @end AND L.end_date >= @start) 
    )
    BEGIN
        SET @replacement_busy = 1;
    END

    IF (@app_dept = @rep_dept AND @replacement_busy = 0)
    BEGIN
        UPDATE [Leave] SET final_approval_status = 'approved' WHERE request_ID = @request_ID;
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        VALUES (@Upperboard_ID, @request_ID, 'approved');
    END
    ELSE
    BEGIN
        UPDATE [Leave] SET final_approval_status = 'rejected' WHERE request_ID = @request_ID;
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        VALUES (@Upperboard_ID, @request_ID, 'rejected');
    END
END
GO

--2.5.J
CREATE PROCEDURE Submit_accidental
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [Leave] (date_of_request, start_date, end_date, final_approval_status)
    VALUES (CAST(GETDATE() AS DATE), @start_date, @end_date, 'pending');

    DECLARE @req_id INT = SCOPE_IDENTITY();

    INSERT INTO Accidental_Leave (request_ID, emp_ID) VALUES (@req_id, @employee_ID);

    DECLARE @hrrep INT;
    SELECT TOP 1 @hrrep = E.employee_ID
    FROM Employee E
    JOIN Employee_Role ER ON ER.emp_ID = E.employee_ID
    WHERE ER.role_name LIKE 'HR_Representative%';

    IF @hrrep IS NOT NULL
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status) VALUES(@hrrep, @req_id, 'pending');
END
GO

--2.5.K
CREATE PROCEDURE Submit_medical
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE,
    @type varchar(50),
    @insurance_status BIT,
    @disability_details varchar(50),
    @document_description varchar(50),
    @file_name varchar(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [Leave] (date_of_request, start_date, end_date, final_approval_status)
    VALUES (CAST(GETDATE() AS DATE), @start_date, @end_date, 'pending');

    DECLARE @req_id INT = SCOPE_IDENTITY();

    INSERT INTO Medical_Leave (request_ID, insurance_status, disability_details, type, Emp_ID)
    VALUES (@req_id, @insurance_status, @disability_details, @type, @employee_ID);

    IF @document_description IS NOT NULL
    BEGIN
        INSERT INTO Document (type, description, file_name, creation_date, status, emp_ID, medical_ID)
        VALUES ('medical', @document_description, @file_name, CAST(GETDATE() AS DATE), 'valid', @employee_ID, @req_id);
    END

    DECLARE @meddoc INT;
    SELECT TOP 1 @meddoc = E.employee_ID FROM Employee E JOIN Employee_Role ER ON ER.emp_ID = E.employee_ID WHERE ER.role_name = 'Medical Doctor';

    DECLARE @hrrep INT;
    SELECT TOP 1 @hrrep = E.employee_ID FROM Employee E JOIN Employee_Role ER ON ER.emp_ID = E.employee_ID WHERE ER.role_name LIKE 'HR_Representative%';

    IF @meddoc IS NOT NULL
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status) VALUES(@meddoc, @req_id, 'pending');

    IF @hrrep IS NOT NULL
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status) VALUES(@hrrep, @req_id, 'pending');
END
GO

--2.5.L
CREATE PROCEDURE Submit_unpaid
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE,
    @document_description varchar(50),
    @file_name varchar(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [Leave] (date_of_request, start_date, end_date, final_approval_status)
    VALUES (CAST(GETDATE() AS DATE), @start_date, @end_date, 'pending');

    DECLARE @req_id INT = SCOPE_IDENTITY();

    INSERT INTO Unpaid_Leave (request_ID, Emp_ID) VALUES (@req_id, @employee_ID);

    IF @document_description IS NOT NULL
    BEGIN
        INSERT INTO Document (type, description, file_name, creation_date, status, emp_ID, unpaid_ID)
        VALUES ('unpaid_memo', @document_description, @file_name, CAST(GETDATE() AS DATE), 'valid', @employee_ID, @req_id);
    END

    DECLARE @isHR BIT = 0;
    IF EXISTS (SELECT 1 FROM Employee_Role WHERE emp_ID = @employee_ID AND role_name LIKE 'HR%')
        SET @isHR = 1;

    DECLARE @president INT;
    SELECT TOP 1 @president = E.employee_ID FROM Employee E JOIN Employee_Role ER ON ER.emp_ID = E.employee_ID WHERE ER.role_name = 'President';

    IF @isHR = 1
    BEGIN
        DECLARE @hrMgr INT;
        SELECT TOP 1 @hrMgr = E.employee_ID FROM Employee E JOIN Employee_Role ER ON ER.emp_ID = E.employee_ID WHERE ER.role_name = 'HR Manager';

        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status) VALUES(@president, @req_id, 'pending');
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status) VALUES(@hrMgr, @req_id, 'pending');
    END
    ELSE
    BEGIN
        DECLARE @hrRep INT;
        SELECT TOP 1 @hrRep = E.employee_ID FROM Employee E JOIN Employee_Role ER ON ER.emp_ID = E.employee_ID WHERE ER.role_name LIKE 'HR_Representative%';

        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status) VALUES(@president, @req_id, 'pending');
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status) VALUES(@hrRep, @req_id, 'pending');
    END
END
GO

--2.5.M
CREATE PROCEDURE Upperboard_approve_unpaids
    @request_ID INT,
    @Upperboard_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Document WHERE unpaid_ID = @request_ID)
    BEGIN
        UPDATE [Leave] SET final_approval_status = 'approved' WHERE request_ID = @request_ID;
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        VALUES (@Upperboard_ID, @request_ID, 'approved');
    END
    ELSE
    BEGIN
        UPDATE [Leave] SET final_approval_status = 'rejected' WHERE request_ID = @request_ID;
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        VALUES (@Upperboard_ID, @request_ID, 'rejected');
    END
END
GO

--2.5.N
CREATE PROCEDURE Submit_compensation
    @employee_ID INT,
    @compensation_date DATE,
    @reason varchar(50),
    @date_of_original_workday DATE,
    @replacement_emp INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [Leave] (date_of_request, start_date, end_date, final_approval_status)
    VALUES (CAST(GETDATE() AS DATE), @compensation_date, @compensation_date, 'pending');

    DECLARE @req_id INT = SCOPE_IDENTITY();

    INSERT INTO Compensation_Leave (request_ID, reason, date_of_original_workday, emp_ID, replacement_emp)
    VALUES (@req_id, @reason, @date_of_original_workday, @employee_ID, @replacement_emp);

    DECLARE @hrrep INT;
    SELECT TOP 1 @hrrep = E.employee_ID
    FROM Employee E
    JOIN Employee_Role ER ON ER.emp_ID = E.employee_ID
    WHERE ER.role_name LIKE 'HR_Representative%';

    IF @hrrep IS NOT NULL
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status) VALUES(@hrrep, @req_id, 'pending');
END
GO

--2.5.O
CREATE PROCEDURE Dean_andHR_Evaluation
    @employee_ID INT,
    @rating INT,
    @comment varchar(50),
    @semester char(3)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Performance (rating, comments, semester, emp_ID)
    VALUES (@rating, @comment, @semester, @employee_ID);
END
GO