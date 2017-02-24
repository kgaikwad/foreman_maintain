class Checks::DiskSpeedMinimalPulp < ForemanMaintain::Check
  for_feature :disk_io
  description 'Check for recommended disk speed - Pulp'
  tags :pre_upgrade

  def run
    assert(feature(:disk_io).speed_pulp >= MIN_SPEED_MBPS, error_message)
  end
end
