create database vignesh

use vignesh

create table sale_order
(
InventoryId int,
ProductId int,
Quantity int,
Rate float,
QuantityInHand int,
ReceivedDate date
)

create table  Product_inventory 
(
ProductId int,
Price int,
Quantity int,
Discount int,
Subtotal int
)


CREATE PROCEDURE UpdateStock 
	-- Add the parameters for the stored procedure here
	@ProductID int, 
	@OrderQuantity int
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Fetch total stock in hand
	DECLARE @TotalStock INT
	SET @TotalStock = (Select SUM(Quantity) from PRODUCT_INVENTORY where ProductID = @ProductID)
	
	-- Check if the available stock is less than ordered quantity
	IF @TotalStock < @OrderQuantity
	BEGIN
		PRINT 'Stock not available'
		RETURN -1
	END
	
	DECLARE @InventoryID INT
	DECLARE @QuantityInHand INT
	-- Declare a CURSOR to hold ID, Quantity
	DECLARE @GetInventoryID CURSOR
 
	SET @GetInventoryID = CURSOR FOR
	SELECT ID, Quantity
	FROM PRODUCT_INVENTORY
	WHERE ProductID = @ProductID
	ORDER BY ReceivedDate
 
	-- Open the CURSOR
	OPEN @GetInventoryID
 
	-- Fetch record from the CURSOR
	FETCH NEXT
	FROM @GetInventoryID INTO @InventoryID, @QuantityInHand
 
	-- Loop if record found in CURSOR
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Check if Order quantity becomes 0
		IF @OrderQuantity = 0
		BEGIN
			PRINT 'Updated Successfully'
			RETURN 1
		END
		-- If Order Qty is less than or equal to Quantity In Hand
		IF @OrderQuantity <= @QuantityInHand 
		BEGIN
			UPDATE PRODUCT_INVENTORY
			SET Quantity = Quantity - @OrderQuantity
			WHERE ID = @InventoryID
			
			SET @OrderQuantity = 0
		END
		-- If Order Qty is greater than Quantity In Hand
		ELSE
		BEGIN
			UPDATE PRODUCT_INVENTORY
			SET Quantity = 0
			WHERE ID = @InventoryID
 
			SET @OrderQuantity = @OrderQuantity - @QuantityInHand
		END
		
		FETCH NEXT
		FROM @GetInventoryID INTO @InventoryID, @QuantityInHand
	END
		
	-- Close and  Deallocate CURSOR
	CLOSE @GetInventoryID
	DEALLOCATE @GetInventoryID
	
END

