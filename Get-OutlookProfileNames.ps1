ForEach($profile in Get-ChildItem -Path HKCU:Software\Microsoft\Office\15.0\Outlook\Profiles ) {
    ForEach($key in Get-ChildItem $profile.pspath) {
        ForEach($val in Get-ItemProperty -Path $key.pspath) {
            ForEach($member in get-member -inputobject $val) {
                If($member.Name -match '^[0-9a-f]+$') {
                    Try {
                        $test_str = [System.Text.Encoding]::Unicode.GetString(($val).($member.Name))
                        if($test_str -eq $profile_name) {
                            "{0}/{1} = {2}" -f ($key.pspath, $member.Name, $test_str)
                        }
                    }
                    Catch {}
                }
            }
        }
    }
}
