class Checks::DiskSpeedMinimalPqsql < ForemanMaintain::Check
  for_feature :disk_io
  description 'Check for recommended disk speed - PgSQL'
  tags :pre_upgrade

  def run
    assert(feature(:disk_io).speed_pgsql >= MIN_SPEED_MBPS, error_message)
  end
end
