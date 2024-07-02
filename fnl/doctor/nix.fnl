(comment "Nix::
         Nix Doctor to check the validity of nix parts of nyoom. E.g::
         - Lualibs
         - Bins
         - packdir
         ")

(let [{:report_start report-start!
       :report_info report-info!
       :report_ok report-ok!
       :report_warn report-warn!
       :report_error report-error!} vim.health]
  (print :hello))
