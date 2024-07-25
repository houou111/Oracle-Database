SELECT p.time,s.id,s.name hostname,p.category,p.name,p.value,p.description
FROM securelog.appliance_properties p,securelog.sources s
WHERE p.time BETWEEN '11-MAR-01 08.52.38.0 AM' AND '11-MAR-21 08.52.38.0 AM'
    AND p.source_id=s.id 
    AND p.category='administration'
ORDER BY time ASC;
