require 'test_helper'

class OneToManyAssociationsTest < CassandraObjectTestCase
  def setup
    super
    @customer = Customer.create :first_name    => "Michael",
                                :last_name     => "Koziarski",
                                :date_of_birth => "1980-08-15"
    assert @customer.valid?, @customer.errors                            
    
    @invoice  = Invoice.create :number=>Time.now.to_i, :total=>Time.now.to_f
    assert @invoice.valid?, @invoice.errors
    
    @customer.invoices << @invoice
  end
  
  test "has set the inverse" do
    assert_equal @customer, @invoice.customer
  end
  
  test "has written the key too" do
    assert_equal @invoice, @customer.invoices.to_a.first
  end
  
  test "handles read-repair" do
    invoices_association = Customer.associations[:invoices]
    invoices_association.add(@customer, MockRecord.new("SomethingStupid"))

    keys_in_cassandra = Customer.connection.get(invoices_association.column_family, @customer.key, "invoices").keys
    
    assert_equal ["SomethingStupid", @invoice.key], keys_in_cassandra
    
    invoices = @customer.invoices.to_a
    assert_equal [@invoice], invoices
    
    keys_in_cassandra = Customer.connection.get(invoices_association.column_family, @customer.key, "invoices").keys
    
    assert_equal [@invoice.key], keys_in_cassandra
  end
  
end