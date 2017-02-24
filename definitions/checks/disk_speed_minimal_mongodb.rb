class Checks::DiskSpeedMinimalMongoDB < ForemanMaintain::Check
  for_feature :disk_io
  description 'Check for recommended disk speed - MongoDB'
  tags :pre_upgrade

  def run
    assert(feature(:disk_io).speed_mongodb >= MIN_SPEED_MBPS, error_message)
  end
end
