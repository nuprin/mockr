class AddFbuidsToUsers < ActiveRecord::Migration
  def self.up
    execute(%(ALTER TABLE `users`
      ADD COLUMN `fbuid` BIGINT NOT NULL,
      ADD INDEX `fbuid` (`fbuid`)))
  end

  def self.down
    execute('ALTER TABLE `users`
      DROP INDEX `fbuid`,
      DROP COLUMN `fbuid`')
  end
end
