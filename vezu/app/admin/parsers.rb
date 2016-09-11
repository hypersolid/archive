ActiveAdmin.register Parser do
  actions :all, :except => [:show]
  
  index do
    column :id
    column "Firm" do |c|
      c.firm.name
    end
    
    default_actions
  end

  
end
