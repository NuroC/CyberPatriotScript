Function disableTasks {
    Unregister-ScheduledTask -TaskPath *Bluetooth*
    Unregister-ScheduledTask -TaskPath *Location*
    Unregister-ScheduledTask -TaskPath *Maps*
    Unregister-ScheduledTask -TaskPath *UPnP*
    Unregister-ScheduledTask -TaskPath '*Plug and Play*'
    Unregister-ScheduledTask -TaskPath '*Windows Error Reporting*'
}

Export-ModuleMember -Function disableTasks