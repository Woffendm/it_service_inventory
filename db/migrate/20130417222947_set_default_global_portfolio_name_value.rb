class SetDefaultGlobalPortfolioNameValue < ActiveRecord::Migration
  def up
    change_column_default :portfolio_names, :global, false
  end

  def down
    change_column_default :portfolio_names, :global, nil
  end
end
