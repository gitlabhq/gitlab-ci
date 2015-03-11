desc 'Security check via brakeman'
 task :brakeman do
   if system("brakeman --skip-files lib/upgrader.rb -w3 -z -x ModelAttributes")
     exit 0
   else
     puts 'Security check failed'
     exit 1
   end
end
