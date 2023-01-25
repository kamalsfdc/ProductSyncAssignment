public class ProductProcessSchedulableBatch implements schedulable{

    public void execute(SchedulableContext sc) {
        ProductProcessBatch b = new ProductProcessBatch(''); 
        database.executebatch(b);
    }
}