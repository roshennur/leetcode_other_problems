create table if not exists employee (id int, salary int);
truncate table employee;

insert into employee (id, salary)
values (1, 100);
insert into employee (id, salary)
values (2, 200);
insert into employee (id, salary)
values (3, 300);

select * from employee;

create or replace function getNthHighestSalary(N int)
returns table (salary int)
as
$$
begin
	RETURN QUERY
	select(
	select distinct e.salary
	from employee AS e
	order by e.salary desc
	limit 1 OFFSET N - 1
	) as s
	WHERE N > 0;
end;
$$
language plpgsql;

select * from getNthHighestSalary(-1);

select * from employee