if object_id('dbo.People', 'U') is not null
    drop table People
go

create table People
(
    PeopleID int identity(1, 1) unique,
    FirstName varchar(255) not null,
    LastName varchar(255) not null,
    City varchar(255) null,
    State varchar(255) null,
    Age tinyint default 0,
    PetID int null,
    constraint PK_People primary key clustered (PeopleID),
    constraint FK_People_PetID foreign key (PetID) references Pet(PetID),
)
go

-- Nothing is mentioned regarding dirty reads to avoid locks
select count(1) from People

select top 1 FirstName
from People
group by FirstName
having count(1) > 1
order by count(1) desc

select * 
from People
where Age between 25 and 45

select * 
into #States
from People
where State in ('Idaho', 'Oregon', 'Utah')

update People
set State = upper(State)

select avg(Age) as 'Average Age'
from People
group by State
having State = 'Idaho'

delete from People
where Age < 20

-- Since I don't know the size of the table, chose batch delete
declare @Rows int
set @Rows = 1

while(@Rows > 0)
begin
    begin transaction
    delete top (5000)
    from People
    where Age < 20

    set @Rows = @@ROWCOUNT
    commit transaction
end

select p1.FirstName, p1.LastName
from People p1
join Pet p2 on p1.PetID = p2.PetID and p2.PetType = 'Dog'

-- There technically could be a tie, so you cannot use top #
select FirstName
from People
group by FirstName
having count(1) = (select top (1) Age from People group by FirstName order by count(1) desc)

-- Or

declare @TopAge tinyint
set @TopAge = (select top (1) Age from People group by FirstName order by count(1) desc)

select FirstName
from People
group by FirstName
having count(1) = @TopAge

-- OR

-- This approach will update in batches
alter table People
add UpperCase bit null

declare @Rows int
set @Rows = 1

while(@Rows > 0)
begin
    begin transaction
    update top (5000) People
    set State = upper(State), UpperCase = 1
    where UpperCase is null

    set @Rows = @@ROWCOUNT
    commit transaction
end

alter table People
drop UpperCase

declare @wheel1 table (ID int not null identity(1,1), Val tinyint not null)
insert into @wheel1 (Val) values (3), (9), (15), (20), (22), (31)

declare @wheel2 table (ID int not null identity(1,1), Val tinyint not null)
insert into @wheel2 (Val) values (27), (17), (12), (14), (23), (7)

declare @wheel3 table (ID int not null identity(1,1), Val tinyint not null)
insert into @wheel3 (Val) values (16), (28), (13), (32), (0), (11)

declare @wheel4 table (ID int not null identity(1,1), Val tinyint not null)
insert into @wheel4 (Val) values (21), (19), (24), (2), (26), (8)

declare @wheel5 table (ID int not null identity(1,1), Val tinyint not null)
insert into @wheel5 (Val) values (34), (33), (0), (10), (18), (5)

declare @wheel6 table (ID int not null identity(1,1), Val tinyint not null)
insert into @wheel6 (Val) values (35), (1), (4), (25), (29), (6)

select w1.ID, w1.Val, w2.ID, w2.Val, w3.ID, w3.Val, w4.ID, w4.Val, w5.ID, w5.Val, w6.ID, w6.Val
from 
(
    select w1.Val AS Val1,
           w2.Val AS Val2,
           w3.Val as Val3,
           w4.Val as Val4,
           w5.Val as Val5,
           w6.Val as Val6
    from @wheel1 as w1,
         @wheel2 as w2,
         @wheel3 as w3,
         @wheel4 as w4,
         @wheel5 as w5,
         @wheel6 as w6
    where w1.Val + w2.Val + w3.Val + w4.Val + w5.Val + w6.Val = 100 
) as ValidCombos
join @wheel1 as w1 on w1.Val = ValidCombos.Val1
join @wheel2 as w2 on w2.Val = ValidCombos.Val2
join @wheel3 as w3 on w3.Val = ValidCombos.Val3
join @wheel4 as w4 on w4.Val = ValidCombos.Val4
join @wheel5 as w5 on w5.Val = ValidCombos.Val5
join @wheel6 as w6 on w6.Val = ValidCombos.Val6