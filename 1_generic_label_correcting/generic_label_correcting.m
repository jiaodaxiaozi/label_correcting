%% clear
clc
clear

%% ���ñ���
g_node_list = []; %����ڵ㼯��
g_link_list = []; %���绡����
g_origin = [];   %����Դ�ڵ�
g_number_of_nodes = 0;%����ڵ����
node_predecessor = [];%ǰ��ڵ㼯��
node_label_cost = [];%�����ǩ����
Max_label_cost = inf; %��ʼ�����ǩ

%% �������������ļ��������������粢��ʼ����ر���
%��ȡ����ڵ�����
df_node = csvread('node.csv',1,0);
g_number_of_nodes = size(df_node,1);
g_node_list = df_node(:,1);
for i = 1 : g_number_of_nodes
    if df_node(i,4)==1
        g_origin=df_node(i,1);
        o_zone_id = df_node(i,5);
    end
end
Distance = ones(g_number_of_nodes,g_number_of_nodes)*Max_label_cost; %�������
node_predecessor = -1*ones(1,g_number_of_nodes);
node_label_cost = Max_label_cost*ones(1,g_number_of_nodes);
node_predecessor(1,g_origin) = 0;
node_label_cost(1,g_origin) = 0;
%��ȡ���绡����
df_link = csvread('road_link.csv',1,0);
g_link_list = df_link(:,2:3);
for i = 1 : size(df_link, 1) 
    Distance(df_link(i,2),df_link(i,3)) = df_link(i,4);
end

%% ���·����⣺ɨ�����绡�����ݼ���������������¾����ǩ
while 1
    v=0; %δ���������������Ľڵ����
    for i = 1 : size(df_link, 1)
        head = g_link_list(i,1);
        tail = g_link_list(i,2);
        if node_label_cost(tail)>node_label_cost(head)+Distance(head,tail)
            node_label_cost(tail)=node_label_cost(head)+Distance(head,tail);
            node_predecessor(tail)=head;
            v=v+1;
        end
    end
    if v==0
        break;
    end  
end

%% ����ǰ��ڵ��������·��
distance_column = [];
path_column = {};
o_zone_id_column = o_zone_id * ones(g_number_of_nodes-1, 1);
d_zone_id_column = [];
agent_id_column = [1:(g_number_of_nodes-1)]';
for i = 1: size(g_node_list, 1)
    destination = g_node_list(i);
    if g_origin ~= destination
        d_zone_id_column = [d_zone_id_column; df_node(i,5)];
        if node_label_cost(destination)==Max_label_cost
            path="";
            distance = 99999;
            distance_column = [distance_column; 99999];
        else
            to_node=destination;
            path=num2str(to_node);
            while node_predecessor(to_node)~=g_origin
                path=strcat(';',path);
                path=strcat(num2str(node_predecessor(to_node)),path);
                g=node_predecessor(to_node);
                to_node=g;
            end
            path=strcat(';',path);
            path=strcat(num2str(g_origin),path);
            distance_column = [distance_column; node_label_cost(i)];
        end
        path_column=[path_column;path];
    end
end

title = {'agent_id','o_zone_id','d_zone_id','node_sequence','distance'};
result_table=table(agent_id_column,o_zone_id_column,d_zone_id_column,path_column,distance_column,'VariableNames',title);
writetable(result_table, 'agent.csv','Delimiter',',','QuoteStrings',true)


