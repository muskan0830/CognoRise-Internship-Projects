CREATE TABLE bigmart (
     Item_Identifier TEXT,	
	 Item_Weight FLOAT,
	 Item_Fat_Content VARCHAR(50),
	 Item_Visibility FLOAT,
	 Item_Type VARCHAR(50),
	 Item_MRP FLOAT,
	 Outlet_Identifier TEXT,	
	 Outlet_Establishment_Year INTEGER,	
	 Outlet_Size VARCHAR(50),
	 Outlet_Location_Type TEXT,
	 Outlet_Type TEXT,
	 Item_Outlet_Sales FLOAT
);

COPY bigmart
FROM 'D:\MY-DATA\Profession- Stage2\INTERNSHIPS\CognoRise Infotech\PROJECT-2 BigMart Sales Data\BigMart_Sales.csv'
ENCODING 'ISO-8859-1'
delimiter ','
CSV HEADER;