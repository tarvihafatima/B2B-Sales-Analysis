with sub as
	(
		select device, username 
		from d_weblog dw 
		where device is not null and username is not null
	),

DeviceUsers as
	(
		select device, count(distinct username) as DeviceUsers
		from sub
		group by 1
	),
DeviceUsersRN as
	(
		select device, row_number() over(order by DeviceUsers desc) rn, DeviceUsers
		from DeviceUsers
	)
	
select device, DeviceUsers
from DeviceUsersRN
where rn<=5
order by rn;