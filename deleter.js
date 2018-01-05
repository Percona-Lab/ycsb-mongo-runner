var count = db.usertable.count()
while (count > 0) {
	var idCount = 0;
	while(idCount <= 5) {
	        db.usertable.aggregate([
        	        { $sample: { size: 1000 }}
	        ]).forEach(function(x) {
        	        db.usertable.remove({ _id: x._id });
	        });
		idCount += 1;
	}
        db.usertable.aggregate([
                { $sample: { size: 10 }}
        ]).forEach(function(x) {
                db.usertable.remove({ field1: x.field1 });
        });
        count = db.usertable.count();
};
