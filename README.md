# automatic-maildrop-filtering

## What is the use case?
This project is specifically useful, if you have a domain for yourself registered with a catch-all email account on it, which means that every possible address `(.*@yourdomain.com
)` will be accepted by your mail server, and you want to sort them somehow.
This way, you are able to give away random, service-specific email addresses with possibly complex folder-structure in them, and this script will create the folder structure for
 you and put every mail in the correct place.
 
### Example time!
An E-Mail being sent to the address `bla.foo.baz@yourdomain.com` will create the following folder structure:

```
Baz
  L Foo
    L Bla <- Your email will be in here.
```

If you receiver another mail for `foo.baz@yourdomain.com`, it will be sorted in the `Foo` folder directly.


## How does it work?
0. Everything before the `@` of the recipient address will be splitted by the dots (`.`)
0. Reverse the order of elements
0. We build the folder path for every element, for example:
    - `.Baz`
    - `.Baz.Foo`
    - `.Baz.Foo.Bar`
0. The "cache" file containing all known folders will be read, paths will be added if not already existent
0. The cache file will be sorted and written back to disk
0. The folder structure described in the cache file will be persisted 
0. The last path will be returned and used by maildrop to deliver the mail

## Pitfalls?
- With the current setup, every mail to `null@yourdomain.com` will be immediately delivered to `/dev/null`.
- The current setup is highly specific for [uberspace](https://uberspace.de/de/) hosting, other providers probably will require deeper changes
- In the current setup, mails will be additionally delivered into a "Mobile" folder meant for use on e.g. smartphones.
- Don't talk about it too loud, you might end up getting various emails from bad friends generating a lot of mail folders for you. You have to be aware, that by using this tool
, you are possibly in the risk of receiving such random address attacks.
- If you want to delete a folder, it's not enough to remove it from your IMAP sync. As the folder cache is only a one-way-sync, it would create it again for the next incoming
 mail. So you have to remove the line from the `folder_structure` cache first, and then remove the folder.
 - Always be careful what to edit in the cache file and filters! you might end up losing email or fucking up your mail infrastructure. Be careful and know what you are doing, plus do some proper filter testing on a spare instance.


## What are the files good for?
- `pull-repo.sh`: pulls the repo, sets permissions right and executes `dos2unix` on all filters to avoid encoding errors.
- `check_folder_structure.sh`: Created a maildir using `maildirmake` for every line thats in the folder cache file (one way sync)
- `add_maildir_folder.sh`: Does the above mentioned logic to split up the address and create the necessary folder structure
- `*.maildrop`: Those are the filters executed by maildrop in order 
- `folder_structure.sample`: That's just to give you an idea how the folder cache looks like. If you mention hard-coded filters in the filter files, you have to take care that
 those folders are inside the folder structure and already exist before trying to deliver into them.

<br>

If everything works, you
- never have to filter any mail manually
- always who sold your e-mail data and where spam came from
- are able to create your folder structure just by making up new email addresses

#IMPORTANT!
I'm not a fully professional bash developer, nor am I familiar enough with mail servers to tell you if that's a good idea. I've been using and developing those scripts for
 ~4 years now and they did a pretty good job most of the time. That doesn't mean there could not be edge cases or bugs that I didn't think of. Use it at your own  risk.
 If this somehow helped you, feel invited to tell me or even contribute ideas or implementations. Have fun filtering your mails!   
