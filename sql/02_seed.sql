BEGIN TRANSACTION;

INSERT INTO category VALUES
('CAT001', 'Racquet', 'Badminton racquets'),
('CAT002', 'Shoes', 'Badminton court shoes'),
('CAT003', 'Shuttlecock', 'Feather and nylon shuttlecocks'),
('CAT004', 'Bag', 'Badminton bags'),
('CAT005', 'Apparel', 'Badminton clothing'),
('CAT006', 'Accessory', 'General badminton accessories'),
('CAT007', 'Grip', 'Replacement grips and overgrips'),
('CAT008', 'String', 'Badminton string products'),
('CAT009', 'Socks', 'Sports socks'),
('CAT010', 'Training Equipment', 'Training and practice equipment');

INSERT INTO brand VALUES
('BR001', 'Yonex', 'Japan'),
('BR002', 'Victor', 'Taiwan'),
('BR003', 'Li-Ning', 'China'),
('BR004', 'Babolat', 'France'),
('BR005', 'Mizuno', 'Japan'),
('BR006', 'Ling Mei', 'China'),
('BR007', 'Adidas', 'Germany'),
('BR008', 'Kawasaki', 'China'),
('BR009', 'Ashaway', 'United States'),
('BR010', 'Apacs', 'Malaysia');

INSERT INTO supplier VALUES
('SUP001', 'Maple Sports Supply', '416-555-1001'),
('SUP002', 'Toronto Court Distributors', '416-555-1002'),
('SUP003', 'Elite Shuttle Wholesale', '416-555-1003'),
('SUP004', 'GTA Racquet Imports', '416-555-1004'),
('SUP005', 'Northern Badminton Goods', '416-555-1005');

INSERT INTO store_location VALUES
('LOC001', '245 Yonge Street', 'Toronto'),
('LOC002', '88 Queen Street West', 'Toronto'),
('LOC003', '1200 Kennedy Road', 'Scarborough'),
('LOC004', '55 Hurontario Street', 'Mississauga'),
('LOC005', '9000 Markham Road', 'Markham');

INSERT INTO staff VALUES
('STF001', 'Clark Gill', 'Store Manager', 'LOC001'),
('STF002', 'Chirag Shetty', 'Sales Associate', 'LOC002'),
('STF003', 'Zheng Si Wei', 'Inventory Coordinator', 'LOC003'),
('STF004', 'Chou Tien Chen', 'Sales Associate', 'LOC004'),
('STF005', 'An Se Young', 'Assistant Manager', 'LOC005');

INSERT INTO customer VALUES
('CUS001', 'Victor Lai', 'victor.lai@example.com'),
('CUS002', 'Loh Kean Yew', 'loh.ky@example.com'),
('CUS003', 'Satwiksairaj Rankireddy', 'satwik.r@example.com'),
('CUS004', 'Thuy Lien Nguyen', 'thuy.nguyen@example.com'),
('CUS005', 'Lakshya Sen', 'lakshya.sen@example.com');

INSERT INTO product VALUES
('PR001', 'Yonex Astrox 100ZZ', 'Professional Racquet', 25999, 32999, 'CAT001', 'BR001', 'SUP001'),
('PR002', 'Yonex Nanoflare 1000Z', 'Speed Racquet', 24999, 31999, 'CAT001', 'BR001', 'SUP002'),
('PR003', 'Yonex Arcsaber 11 Pro', 'Control Racquet', 23999, 30999, 'CAT001', 'BR001', 'SUP003'),
('PR004', 'Yonex Power Cushion 65 Z3', 'Badminton Shoes', 14999, 19999, 'CAT002', 'BR001', 'SUP004'),
('PR005', 'Yonex Aerosensa 50', 'Feather Shuttlecock', 4200, 5499, 'CAT003', 'BR001', 'SUP005'),
('PR006', 'Victor Master Ace', 'Feather Shuttlecock', 3950, 4999, 'CAT003', 'BR002', 'SUP003'),
('PR007', 'Li-Ning A+ 80 Pro', 'Feather Shuttlecock', 3499, 4499, 'CAT003', 'BR003', 'SUP005'),
('PR008', 'Yonex Pro Tournament Bag', 'Racquet Bag', 8999, 11999, 'CAT004', 'BR001', 'SUP002'),
('PR009', 'Li-Ning Game Shirt', 'Badminton Apparel', 2499, 3999, 'CAT005', 'BR003', 'SUP001'),
('PR010', 'Yonex Super Grap', 'Overgrip', 550, 999, 'CAT007', 'BR001', 'SUP004');

INSERT INTO inventory VALUES
('INV001', 'PR001', 'LOC001', 8, 5, '2026-02-01'),
('INV002', 'PR002', 'LOC002', 4, 6, '2026-02-10'),
('INV003', 'PR003', 'LOC003', 0, 4, '2026-01-25'),
('INV004', 'PR004', 'LOC004', 12, 5, '2026-02-12'),
('INV005', 'PR005', 'LOC005', 25, 10, '2026-02-14'),
('INV006', 'PR006', 'LOC001', 15, 8, '2026-02-05'),
('INV007', 'PR007', 'LOC002', 6, 8, '2026-02-07'),
('INV008', 'PR008', 'LOC003', 14, 4, '2026-02-22'),
('INV009', 'PR009', 'LOC004', 10, 6, '2026-02-11'),
('INV010', 'PR010', 'LOC005', 20, 10, '2026-02-15');

INSERT INTO sale VALUES
('SAL001', '2026-01-10', 'Debit', 'STF001', 'CUS001'),
('SAL002', '2026-01-15', 'Credit', 'STF002', 'CUS002'),
('SAL003', '2026-01-22', 'Cash', 'STF003', 'CUS003'),
('SAL004', '2026-02-01', 'Debit', 'STF004', 'CUS004'),
('SAL005', '2026-02-05', 'Credit', 'STF005', 'CUS005'),
('SAL006', '2026-02-08', 'Online', 'STF001', 'CUS002'),
('SAL007', '2026-02-10', 'Debit', 'STF002', 'CUS003'),
('SAL008', '2026-02-14', 'Credit', 'STF003', 'CUS004'),
('SAL009', '2026-02-18', 'Cash', 'STF004', 'CUS005'),
('SAL010', '2026-02-20', 'Debit', 'STF005', 'CUS001');

INSERT INTO sale_item VALUES
('SI001', 'SAL001', 'PR001', 1, 32999),
('SI002', 'SAL001', 'PR010', 1, 999),
('SI003', 'SAL002', 'PR004', 1, 19999),
('SI005', 'SAL003', 'PR005', 2, 5499),
('SI006', 'SAL003', 'PR006', 1, 4999),
('SI007', 'SAL004', 'PR008', 1, 11999),
('SI008', 'SAL005', 'PR007', 1, 4499),
('SI009', 'SAL006', 'PR002', 1, 31999),
('SI010', 'SAL007', 'PR003', 1, 30999),
('SI011', 'SAL008', 'PR005', 1, 5499),
('SI012', 'SAL009', 'PR010', 1, 999),
('SI013', 'SAL010', 'PR006', 1, 4999);

COMMIT;
