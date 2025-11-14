--USE WSS_Content_fdf313d767584a3faf5643748db7c279  
-- IP 10.240.50.50
WITH T1 AS(
select distinct 
    Username 
    ,[sharepoint group]
    ,(charindex('/',reverse(ScopeUrl))-1) as ReportLength
    ,ScopeUrl
    from (
SELECT DISTINCT
CASE WHEN PATINDEX('%\%', FullUrl) > 0 THEN LEFT(FullUrl, PATINDEX('%\%', FullUrl) - 1) ELSE FullUrl END AS [Site],
Webs.Title,
Webs.FullUrl,
Perms.ScopeUrl,
UserInfo.tp_Login As Account,
CASE WHEN UserInfo.tp_DomainGroup>0 THEN NULL ELSE UserInfo.tp_Title END AS Username,
CASE WHEN UserInfo.tp_DomainGroup>0 THEN UserInfo.tp_Login ELSE NULL END AS [AD Group],
NULL AS [SharePoint Group],
Roles.Title AS RoleTitle,
Roles.PermMask
FROM
dbo.RoleAssignment
INNER JOIN dbo.UserInfo ON RoleAssignment.SiteId = UserInfo.tp_SiteID AND UserInfo.tp_ID = RoleAssignment.PrincipalId
INNER JOIN dbo.Perms ON Perms.SiteId = RoleAssignment.SiteId AND Perms.ScopeId = RoleAssignment.ScopeId
INNER JOIN dbo.Roles ON RoleAssignment.SiteId = Roles.SiteId AND RoleAssignment.RoleId = Roles.RoleId
INNER JOIN dbo.Webs ON Roles.SiteId = Webs.SiteId AND Roles.WebId = Webs.Id
WHERE
Roles.Type<>1 AND tp_Deleted=0
UNION
-- Query to get all the SharePoint groups assigned to roles
SELECT DISTINCT
CASE WHEN PATINDEX('%\%', FullUrl) > 0 THEN LEFT(FullUrl, PATINDEX('%\%', FullUrl) - 1) ELSE FullUrl END AS [Site],
Webs.Title,
Webs.FullUrl,
Perms.ScopeUrl,
UserInfo.tp_Login As Account,
CASE WHEN UserInfo.tp_DomainGroup>0 THEN NULL ELSE UserInfo.tp_Title END AS Username,
CASE WHEN UserInfo.tp_DomainGroup>0 THEN UserInfo.tp_Login ELSE NULL END AS [AD Group],
Groups.Title AS [SharePoint Group],
Roles.Title AS RoleTitle,
Roles.PermMask
FROM
dbo.RoleAssignment
INNER JOIN dbo.Roles ON RoleAssignment.SiteId = Roles.SiteId AND RoleAssignment.RoleId = Roles.RoleId
INNER JOIN dbo.Perms ON Perms.SiteId = RoleAssignment.SiteId AND Perms.ScopeId = RoleAssignment.ScopeId
INNER JOIN dbo.Webs ON Roles.SiteId = Webs.SiteId AND Roles.WebId = Webs.Id
INNER JOIN dbo.Groups ON RoleAssignment.SiteId = Groups.SiteId AND RoleAssignment.PrincipalId = Groups.ID
INNER JOIN dbo.GroupMembership ON GroupMembership.SiteId = Groups.SiteId AND GroupMembership.GroupId = Groups.ID
INNER JOIN dbo.UserInfo ON GroupMembership.SiteId = UserInfo.tp_SiteID AND GroupMembership.MemberId = UserInfo.tp_ID
WHERE
Roles.Type<>1 AND tp_Deleted=0
) a
where 
username like '%munthe%' and 
--[SharePoint Group] LIKE '%Report Akreditasi PDPT%' AND
--ScopeUrl LIKE'%Mahasiswa Diterima%' AND
ScopeUrl <> ''
),t2 as(
SELECT DISTINCT
    Username,
	--RIGHT(SCOPEURL,CAST(ReportLength AS int)) as ReportTitle,
    ScopeUrl as LinkReport,
    [SharePoint Group]
FROM T1
)
select * from t2
--WHERE ReportTitle='Data GSLC Log Book (Detail).rdl'