class Checks::DiskSpeedMinimal < ForemanMaintain::Check
  for_feature :disk_io
  description 'Check for recommended disk speed of pulp, mongodb, pgsql dir.'
  tags :pre_upgrade

  def run
    assert(feature(:disk_io).pass?, "Disk speed should be atleast #{MIN_SPEED_MBPS} MB/sec")
  end
end
