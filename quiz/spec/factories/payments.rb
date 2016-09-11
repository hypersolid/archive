FactoryGirl.define do
  factory :payment do
    status "ok"
    transaction_id "{2B7B1AF7-93B2-489B-A11D-80DCA6AD9F79}"
    query_string "sn=GSWP&login=sa7eveDaw7&adminpwd=2HetRa2HubRerUZe&commtype=PAYMENT&userid=12345&dtdatetime=20031110123000&currency=GBP&amount=1.00&set_amount=1.00&paymentid=CH&pbctrans=%7B2B7B1AF7-93B2-489B-A11D-80DCA6AD9F79%7D&merchtrans=99&livemode=T&hash=76460011b331f91c57ef8d3f0ae23090"
  end
end